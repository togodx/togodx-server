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
  option :format, aliases: '-f', type: :string, desc: 'File format', enum: %w[csv tsv json]

  def import(file = '-')
    require_relative '../../config/environment'

    format = options[:format] || File.extname(file)[1..] || raise("No value provided for options '--format'")

    total = 0
    ActiveRecord::Base.transaction do
      say "Importing relations"
      time = Benchmark.realtime do
        RecordReader.open(file, format: format).records.each_slice(1000) do |g|
          records = g.map { |hash| hash.values_at(:db1, :entry1, :db2, :entry2) }
          Relation.import records
          total += records.size
        end
      end
      say "  -> #{'%.3f' % time} sec"

      say "Imported #{total} #{'relation'.pluralize(total)}"
    end
  end
end
