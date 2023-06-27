require 'thor'

class AttributeTask < Thor
  include Thor::Actions

  namespace 'togodx:attribute'

  class << self
    def exit_on_failure?
      true
    end
  end

  desc 'import', 'Import attributes to database'

  def import
    require_relative '../../config/environment'

    Rails.configuration.togodx[:attributes].each do |_key, config|
      Attribute::EntryPoint.run! **config
    end
  end

  desc 'list', 'List all imported attributes'
  option :format, aliases: '-f', type: :string, required: true, desc: 'File format', enum: %w[csv tsv json], default: 'json'

  def list
    require_relative '../../config/environment'

    output = case options[:format]
             when /^[ct]sv$/
               CSV.generate(col_sep: options[:format] == 'csv' ? ',' : "\t") do |csv|
                 csv << (headers = Attribute.column_names)
                 Attribute.all.each do |attribute|
                   csv << attribute.attributes.values_at(*headers)
                 end
               end
             when 'json'
               JSON.pretty_generate(Attribute.all.map(&:attributes))
             else
               raise ArgumentError, "Unknown format: #{options[:format]}"
             end

    puts output
  end

  desc 'drop <KEY1>, <KEY2>, ...', 'Drop an attribute'

  def drop(*keys)
    require_relative '../../config/environment'

    keys.each do |key|
      sql = <<~SQL
      DROP TABLE IF EXISTS table#{Attribute.from_key(key).id};
      SQL

      say_error sql
      ActiveRecord::Base.connection.execute sql
    end
  end

  desc 'drop_all', 'Drop all attributes'

  def drop_all
    require_relative '../../config/environment'

    drop(*Attribute.all.pluck(:key))
  end

  desc 'clear_cache', 'Clear cache'

  def clear_cache
    require_relative '../../config/environment'

    FileUtils.rm_rf ApplicationInteraction.new.cache_dir / 'attributes'
  end
end
