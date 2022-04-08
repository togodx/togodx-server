class LocateIdentifiers < ApplicationInteraction
  string :attribute
  string :source
  array :queries do
    string
  end
  string :node, default: nil

  def execute
    attr = Attribute.from_api(attribute)
    target = attr.dataset
    model = attr.table

    queries = self.queries
    if source != target
      queries = Relation.from_pair(source, target).table.convert(source, target, queries).values.flatten.uniq
    end

    model.locate(queries, node)
  end
end
