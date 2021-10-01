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

    if source != target
      self.queries = Relation.convert(source, target, queries)
    end

    attr.table.locate(queries, node)
  end
end
