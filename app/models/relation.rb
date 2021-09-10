class Relation < ApplicationRecord
  class << self
    # @param [String] source
    # @param [String] target
    # @param [Array<String>] entries
    # @return [Array<String>]
    def convert(source, target, entries)
      where(db1: source, db2: target, entry1: entries).map(&:entry2)
    end

    # @param [String] source
    # @param [String] target
    # @param [Array<String>] entries
    # @return [Array<String>]
    def reverse(source, target, entries)
      where(db1: source, db2: target, entry2: entries).map(&:entry1)
    end
  end
end
