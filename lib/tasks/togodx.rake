namespace :togodx do
  require 'csv'
  require 'dag'
  require 'activerecord-import'

  # Example: rails 'togodx:load[gene_chromosome_ensembl]' < ../togodx-server-sample-data/gene_chromosome_ensembl.csv
  #   Input: For classification -> 4 columns required [classification, classification_label, classification_parent, leaf]
  #          For distribution   -> 5 columns required [distribution, distribution_label, distribution_value, bin_id, bin_label]
  desc 'Load classification or distribution CSV to database'
  task :load, %i[api] => :environment do |_task, args|
    raise ArgumentError, 'No API name given' unless args[:api]

    Rails.logger = Logger.new(STDERR)
    ActiveRecord::Base.logger = nil

    attribute = Attribute.from_api(args[:api])
    schema = File.read(File.expand_path(File.join('db', 'schema.rb'), Rails.root))

    template_table = attribute.datamodel.underscore.pluralize
    m = schema.match(/^\s*create_table "#{template_table}".*?end$/m)
    raise RuntimeError, 'Failed to obtain migration definition' unless m

    table = "table#{attribute.id}"
    ActiveRecord::Migration.class_eval do
      eval m[0].gsub(template_table, table)
    end

    klass = Class.new(attribute.datamodel.constantize) do |klass|
      klass.table_name = table

      def klass.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end
    end

    columns = case attribute.datamodel
              when Attribute::DataModel::CLASSIFICATION
                %i[classification classification_label classification_parent leaf]
              when Attribute::DataModel::DISTRIBUTION
                %i[distribution distribution_label distribution_value bin_id bin_label]
              else
                raise RuntimeError, "Unknown data model: #{attribute.datamodel}"
              end

    time = Benchmark.realtime do
      CSV.new(STDIN).each_slice(1000) do |g|
        klass.import columns, g
      end
    end

    Rails.logger.info('Rake') { "import #{(n = klass.count)} #{'record'.pluralize(n)} to #{table}: #{'%.3f' % time} sec" }
  end

  desc 'Add index for awesome_nested_set to all classification tables'
  task rebuild: :environment do
    Rails.logger = Logger.new(STDERR)
    ActiveRecord::Base.logger = nil

    Attribute.classifications.each do |attribute|
      next if (table = attribute.table).built?

      table_name = table.table_name
      Rails.logger.info('Rake') { "rebuilding #{table_name} (#{attribute.api})" }

      time = Benchmark.realtime do
        ActiveRecord::Base.connection.execute <<~SQL
          UPDATE #{table_name}
          SET parent_id = (
            SELECT parent.id
            FROM #{table_name} parent
            WHERE #{table_name}.classification_parent = parent.classification
            ORDER BY parent.id
            LIMIT 1
          )
          WHERE EXISTS(
            SELECT 1
            FROM #{table_name} parent
            WHERE #{table_name}.classification_parent = parent.classification
            AND #{table_name}.classification_parent IS NOT NULL
          );
        SQL
      end
      Rails.logger.info('Rake') { "  update parent id: #{'%.3f' % time} sec" }

      time = Benchmark.realtime do
        table.rebuild!
      end

      Rails.logger.info('Rake') { "  rebuild index: #{'%.3f' % time} sec" }
    end
  end

  require 'faraday'

  desc 'Retrieve API cache.'
  task :retrieve_cache, ['api'] => :environment do |_task, args|
    Rails.logger = Logger.new(STDERR)
    ActiveRecord::Base.logger = Rails.logger

    cache_path = Rails.root.join('tmp', 'cache', 'api')
    FileUtils.mkdir_p cache_path unless cache_path.exist?

    prefix = URI.parse(Rails.configuration.togodx.dig(:api, :prefix))

    attributes = if args['api'].nil?
                   Attribute.all
                 else
                   Attribute.where(api: [args['api']] + args.extras)
                 end

    attributes.each do |attribute|
      file = cache_path.join("#{attribute.api}.json")
      if file.exist?
        Rails.logger.info('Rake') { "#{file.relative_path_from(Rails.root)} already exists, skipped" }
        next
      end

      url = prefix.merge(attribute.api)

      Rails.logger.info('Rake') { "retrieving from #{url}" }

      response = nil
      time = Benchmark.realtime do
        response = Faraday.new(url: url.merge('/')).get(url.request_uri) do |req|
          req.options.timeout = 1.hour
          req.headers['Accept'] = 'application/json'
        end
      end

      unless response&.status == 200
        Rails.logger.error('Rake') { "  failed with status #{response&.status}: #{'%.3f' % time} sec\n#{response&.body}" }
        next
      end

      File.open(file, 'w') do |f|
        response&.body&.split("\n")&.each do |x|
          begin
            f.puts x
          rescue Encoding::UndefinedConversionError => e
            f.puts((safe = x.force_encoding('UTF-8')))
            Rails.logger.warn('Rake') { "  #{e.message}" }
            Rails.logger.warn('Rake') { "    error_char: #{e.error_char}" }
            Rails.logger.warn('Rake') { "        source: #{x}" }
            Rails.logger.warn('Rake') { "     converted: #{safe}" }
          end
        end
      end

      Rails.logger.info('Rake') { "  succeeded: #{'%.3f' % time} sec" }
    end
  end

  desc 'Load classification or distribution from cached api json'
  task :import_cache, %i[api] => :environment do |_task, args|
    Rails.logger = Logger.new(STDERR)
    ActiveRecord::Base.logger = nil

    cache_path = Rails.root.join('tmp', 'cache', 'api')

    attributes = if args['api'].nil?
                   Attribute.all
                 else
                   Attribute.where(api: [args['api']] + args.extras)
                 end

    attributes.each do |attribute|
      schema = File.read(File.expand_path(File.join('db', 'schema.rb'), Rails.root))

      model = attribute.to_model_class
      template_table = model.table_name
      m = schema.match(/^\s*create_table "#{template_table}".*?end$/m)
      raise RuntimeError, 'Failed to obtain migration definition' unless m

      table = "table#{attribute.id}"
      ActiveRecord::Migration.class_eval do
        eval m[0].gsub(template_table, table)
      end

      file = cache_path.join("#{attribute.api}.json")
      unless file.exist?
        Rails.logger.info('Rake') { "#{file.relative_path_from(Rails.root)} not found, skipped" }
        next
      end

      klass = Class.new(model) do |klass|
        klass.table_name = table

        def klass.model_name
          ActiveModel::Name.new(self, nil, "temp")
        end
      end

      converter = case attribute.datamodel
                  when Attribute::DataModel::CLASSIFICATION
                    lambda do |hash|
                      {
                        classification: hash['id'].to_s,
                        classification_label: hash['label'].to_s,
                        classification_parent: hash['parent'].to_s,
                        leaf: hash['leaf'] == true
                      }
                    end
                  when Attribute::DataModel::DISTRIBUTION
                    lambda do |hash|
                      {
                        distribution: hash['id'].to_s,
                        distribution_label: hash['label'].to_s,
                        distribution_value: hash['value'].to_s,
                        bin_id: hash['binId'].to_s,
                        bin_label: hash['binLabel'].to_s
                      }
                    end
                  else
                    raise NameError, "Invalid data model: #{attribute.datamodel}"
                  end

      time = Benchmark.realtime do
        json = JSON.load_file(file)

        if %w[protein_biological_process_uniprot protein_cellular_component_uniprot protein_molecular_function_uniprot]
             .include? args['api'] # TODO: add flag whether if the tree is dag to `Attribute` model?
          json = Dag.new(json).to_tree
        end

        json.map { |x| converter.call(x) }.each_slice(1000) do |values|
          klass.import values
        end
      end

      Rails.logger.info('Rake') { "import #{(n = klass.count)} #{'record'.pluralize(n)} to #{table}: #{'%.3f' % time} sec" }
    end
  end
end
