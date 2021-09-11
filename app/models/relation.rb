class Relation < ApplicationRecord
  class << self
    # @param [String] source
    # @param [String] target
    # @param [Array<String>] entries
    # @param [Hash] options
    # @return [Array<String>]
    def convert(source, target, entries, **options)
      if options[:reverse]
        where(db1: source, db2: target, entry2: entries).map(&:entry1)
      else
        where(db1: source, db2: target, entry1: entries).map(&:entry2)
      end
    end
  end
end
