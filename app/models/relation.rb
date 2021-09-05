class Relation < ApplicationRecord
  class << self
    # @param [String] source
    # @param [String] target
    # @param [String] entries
    # @return [ActiveRecord::Relation<Relation>]
    def convert(source, target, entries)
      where(db1: source, db2: target, entry1: entries)
    end
  end
end
