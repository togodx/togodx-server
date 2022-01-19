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
    idsets = filters.select { |filter| filter.has_key?(:nodes) }.map do |filter|
      entries = []

      attribute = Attribute.from_api(filter[:attribute])
      model = attribute.table
      source = attribute.dataset

      filter[:nodes].each do |condition|
        # OR (within a same attribute)
        entries += model.entries(condition)
      end

      if source != target
        entries = Relation.pairs(source, target, entries).map { |x| x[1] }
      end

      queries.present? ? entries.uniq & queries : entries.uniq
    end

    # AND (among different attributes)
    idsets.inject { |sum, n| sum.intersection(n) } || []
  end
end
