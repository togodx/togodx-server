class FilterIdentifiers < ApplicationInteraction
  string :target

  array :filters, default: [] do
    hash do
      string :attribute
      array :nodes, default: [] do
        string
      end
    end
  end

  array :queries, default: [] do
    string
  end

  def execute
    sets = filters.select { |filter| filter.has_key?(:nodes) }.map do |filter|
      entries = []

      attribute = Attribute.from_key(filter[:attribute])
      model = attribute.table
      source = attribute.dataset

      filter[:nodes].each do |condition|
        # OR (within a same attribute)
        entries += model.entries(condition)
      rescue ActiveRecord::RecordNotFound
        nil
      end

      if source != target
        entries = Relation.from_pair(source, target).table.pairs(entries).map { |x| x[1] }
      end

      queries.present? ? entries.uniq & queries : entries.uniq
    end

    # AND (among different attributes)
    sets.inject { |sum, n| sum.intersection(n) } || []
  rescue ApplicationRecord::AttributeNotFound => e
    errors.add(:attribute, e.message) and return
  end
end
