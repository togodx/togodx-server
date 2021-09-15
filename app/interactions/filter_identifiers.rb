class FilterIdentifiers < ApplicationInteraction
  string :target
  array :filters do
    hash do
      string :propertyId
      array :categoryIds, default: [] do
        string
      end
    end
  end

  def execute
    idsets = filters.select { |x| x.has_key?(:categoryIds) }.map do |hash|
      entries = []

      attribute = Attribute.from_api(hash[:propertyId])
      table = attribute.table
      source = attribute.dataset

      hash[:categoryIds].each do |condition|
        # OR (within a same attribute)
        entries += table.entries(condition)
      end

      if source != target
        entries = Relation.convert(source, target, entries)
      end

      entries.uniq
    end

    # AND (among different attributes)
    idsets.inject { |sum, n| sum.intersection(n) } || []
  end
end
