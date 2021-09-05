class Relation < ApplicationRecord
  def self.convert(source, target, entries)
    self.take(3)
#    self.where(db1: source, db2: target, entry1: entries)
  end
end
