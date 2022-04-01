class Relation < ApplicationRecord
  class << self
    # @param [String] source
    # @param [String] target
    # @param [Array<String>] entries
    # @param [Hash] options
    # @return [Hash]
    def convert(source, target, entries, **options)
      pairs(source, target, entries, **options)
        .group_by { |x| x[0] }
        .map { |k, v| [k, v.map { |x| x[1] }] }
        .to_h
    end

    # @param [String] source
    # @param [String] target
    # @param [Array<String>] entries
    # @param [Hash] options
    # @return [Array<Array<String>>]
    def pairs(source, target, entries, **options)
      if options[:reverse]
        where(db1: source, db2: target, entry2: entries)
          .pluck(:entry2, :entry1)
      else
        where(db1: source, db2: target, entry1: entries)
          .pluck(:entry1, :entry2)
      end
    end
  end
end
