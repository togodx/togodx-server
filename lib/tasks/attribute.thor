require 'thor'
require_relative '../util/record_reader'

class AttributeTask < Thor
  include Thor::Actions

  namespace 'togodx:attribute'

  class << self
    def exit_on_failure?
      true
    end
  end

  desc 'import <FILE>', 'Import attributes to database'
  option :format, aliases: '-f', type: :string, desc: 'File format', enum: %w[csv tsv json]

  def import(file = '-')
    require_relative '../../config/environment'

    reader_options = {
      format: options[:format] || File.extname(file)[1..] || raise("No value provided for options '--format'")
    }.compact

    total = 0
    i = 0
    RecordReader.open(file, **reader_options).records.each do |record|
      total += 1
      Attribute.find_or_create_by(api: record[:api]) do |attribute|
        i += 1
        attribute.dataset = record[:dataset]
        attribute.datamodel = record[:datamodel]
      end
    end

    say "Imported #{i} #{'attribute'.pluralize(i)}" \
        "#{" (#{total - i} #{'attribute'.pluralize(total - i)} already exist)" unless (total - i).zero? }"
  end

  desc 'list', 'List all imported attributes'
  option :format, aliases: '-f', type: :string, required: true, desc: 'File format', enum: %w[csv tsv json], default: 'json'

  def list
    require_relative '../../config/environment'

    case options[:format]
    when /^[ct]sv$/
      output = CSV.generate(col_sep: options[:format] == 'csv' ? ',' : "\t") do |csv|
        csv << (headers = Attribute.column_names)
        Attribute.all.each do |attribute|
          csv << attribute.attributes.values_at(*headers)
        end
      end
    when 'json'
      output = JSON.pretty_generate(Attribute.all.map(&:attributes))
    else
      raise ArgumentError, "Unknown format: #{options[:format]}"
    end

    puts output
  end
end
