require 'activerecord-import'
require 'thor'
require_relative '../util/record_reader'

class DistributionTask < Thor
  include Thor::Actions

  namespace 'togodx:distribution'

  class << self
    def exit_on_failure?
      true
    end
  end

  desc 'drop', 'Drop a distribution'
  option :api, aliases: '-a', type: :string, required: true, desc: 'API name for the attribute'

  def drop
    require_relative '../../config/environment'

    ActiveRecord::Base.connection.execute <<~SQL
      DROP TABLE IF EXISTS table#{Attribute.from_api(options[:api]).id};
    SQL
  end

  desc 'import <FILE>', 'Import a distribution'
  option :api, aliases: '-a', type: :string, required: true, desc: 'API name for the attribute'
  option :format, aliases: '-f', type: :string, desc: 'File format', enum: %w[csv tsv json]

  def import(file = '-')
    require_relative '../../config/environment'

    format = options[:format] || File.extname(file)[1..] || raise("No value provided for options '--format'")

    check_table

    total = 0
    ActiveRecord::Base.transaction do
      table = create_table

      say "Importing distribution"
      time = Benchmark.realtime do
        RecordReader.open(file, format: format).records.each_slice(1000) do |g|
          records = g.map do |hash|
            {
              distribution: hash[:id],
              distribution_label: hash[:label],
              distribution_value: hash[:value],
              bin_id: hash[:binId],
              bin_label: hash[:binLabel]
            }
          end
          table.import records
          total += records.size
        end
      end
      say "  -> #{'%.3f' % time} sec"

      say "Imported #{total} #{'distribution'.pluralize(total)}"
    end
  end

  private

  no_commands do
    def check_table
      begin
        table = Attribute.from_api(options[:api]).table
        table.first
        warn "Table for #{options[:api]} already exists. Drop the table by `#{$0} classification drop --api #{options[:api]}`, first."
        exit(false)
      rescue ActiveRecord::StatementInvalid
        # Table does not exist
      end
    end

    def create_table
      attribute = Attribute.from_api(options[:api])
      schema = File.read(Rails.root.join('db', 'schema.rb'))

      template_table = attribute.datamodel.underscore.pluralize
      m = schema.match(/^\s*create_table "#{template_table}".*?end$/m)
      raise RuntimeError, 'Failed to obtain migration definition' unless m

      table = "table#{attribute.id}"
      ActiveRecord::Migration.class_eval do
        eval m[0].gsub(template_table, table)
      end

      Class.new(attribute.datamodel.classify.constantize) do |klass|
        klass.table_name = table

        def klass.model_name
          ActiveModel::Name.new(self, nil, "temp")
        end
      end
    end
  end
end
