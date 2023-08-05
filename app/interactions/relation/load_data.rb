# frozen_string_literal: true

class Relation
  class LoadData < ApplicationInteraction
    string :source
    string :target
    object :file, class: Pathname, converter: :new

    def execute
      pair = [source, target].sort
      table = Relation.from_pair(*pair).table

      format = file.extname[1..] || raise('Failed to obtain file extension')

      logger.info(self.class) { 'Loading relation' }

      total = 0
      time = Benchmark.realtime do
        ActiveRecord::Base.transaction do
          RecordReader.open(file.to_s, format: format).records.each_slice(1000) do |g|
            records = g.map do |hash|
              {
                source: hash[:source],
                target: hash[:target]
              }
            end
            table.import records
            total += records.size
          end
        end
      end

      logger.info(self.class) { "  -> #{'%.3f' % time} sec" }
      logger.info(self.class) { "Loaded #{total} #{'row'.pluralize(total)}" }
    end
  end
end
