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

  array :mappings, default: [] do
    string
  end

  def execute
    idsets = filters.select { |x| x.has_key?(:nodes) }.map do |hash|
      entries = []

      attribute = Attribute.from_api(hash[:attribute])
      table = attribute.table
      source = attribute.dataset

      hash[:nodes].each do |condition|
        # OR (within a same attribute)
        entries += table.entries(condition)
      end

      if source != target
        entries = Relation.convert(source, target, entries)
      end

      mappings.present? ? entries.uniq & mappings : entries.uniq
    end

    # AND (among different attributes)
    idsets.inject { |sum, n| sum.intersection(n) } || []
  end
end
