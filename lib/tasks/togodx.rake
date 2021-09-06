namespace :togodx do
  require 'csv'
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
      table_name = attribute.table.table_name
      Rails.logger.info('Rake') { "rebuilding #{table_name} (#{attribute.api})" }

      time = Benchmark.realtime do
        ActiveRecord::Base.connection.execute <<~SQL
          UPDATE #{table_name}
          SET parent_id = (
            SELECT parent.id
            FROM #{table_name} parent
            WHERE #{table_name}.classification_parent = parent.classification
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
        attribute.table.rebuild!
      end

      Rails.logger.info('Rake') { "  rebuild index: #{'%.3f' % time} sec" }
    end
  end
end
