class LocateIdentifiers < ApplicationInteraction
  string :api
  string :target
  string :source
  array :queries do
    string
  end
  string :node, default: nil

  def execute
    if source != target
      self.queries = Relation.convert(source, target, queries)
    end

    Attribute.from_api(api).table.locate(queries, node)
  end
end
