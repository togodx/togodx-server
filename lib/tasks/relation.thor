require 'activerecord-import'
require 'thor'
require_relative '../util/record_reader'

class RelationTask < Thor
  include Thor::Actions

  namespace 'togodx:relation'

  class << self
    def exit_on_failure?
      true
    end
  end

  desc 'import <FILE>', 'Import relations'
  option :source, type: :string, required: true, desc: 'Dataset name'
  option :target, type: :string, required: true, desc: 'Dataset name'
  option :format, aliases: '-f', type: :string, desc: 'File format', enum: %w[csv tsv json]

  def import(file = '-')
    require_relative '../../config/environment'

    format = options[:format] || File.extname(file)[1..] || raise("No value provided for options '--format'")

    if (not_found = [options[:source], options[:target]].reject { |x| Attribute.find_by(dataset: x) }).present?
      warn "Dataset name not found in attributes: #{not_found.join(', ')}"
      exit false
    end

    if options[:target] < options[:source]
      warn '`source` must precede `target` in alphabetical order.'
      exit false
    end

    create_table if table_absent

    table = Relation.from_pair(options[:source], options[:target]).table

    total = 0
    ActiveRecord::Base.transaction do
      say "Importing relations to #{table.table_name}"
      time = Benchmark.realtime do
        RecordReader.open(file, format: format).records.each_slice(1000) do |g|
          records = g.map { |hash| hash.values_at(:source, :target) }
          table.import %i[source target], records, on_duplicate_key_ignore: true
          total += records.size
        end
      end
      say "  -> #{'%.3f' % time} sec"

      say "Imported #{total} #{'relation'.pluralize(total)}"
    end
  end

  private

  no_commands do
    def table_absent
      begin
        return true unless (relation = Relation.find_by(source: options[:source], target: options[:target]))

        relation.table.first

        false
      rescue ActiveRecord::StatementInvalid
        # Table does not exist
        true
      end
    end

    def create_table
      relation = Relation.create!(source: options[:source], target: options[:target])

      schema = File.read(Rails.root.join('db', 'schema.rb'))
      m = schema.match(/^\s*create_table "relation".*?end$/m)
      raise RuntimeError, 'Failed to obtain migration definition' unless m

      table_name = "relation#{relation.id}"
      ActiveRecord::Migration.class_eval do
        eval m[0].gsub('relation', table_name)
      end

      klass = Class.new(ApplicationRecord) do
        include Relation::Base
      end
      klass.table_name = "#{table_name}"

      Object.const_set(table_name.classify.to_sym, klass)

      true
    end
  end
end
