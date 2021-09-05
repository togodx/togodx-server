class Relation < ApplicationRecord
  def self.convert(source, target, entries)
    self.where(db1: source, db2: target, entry1: entries).map{|x| x.entry2}
  end
end
