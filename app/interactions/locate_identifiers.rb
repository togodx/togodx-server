class LocateIdentifiers < ApplicationInteraction
  string :attribute
  string :source
  array :queries do
    string
  end
  string :node, default: nil
  boolean :hierarchy, default: false

  def execute
    attr = Attribute.from_api(attribute)
    target = attr.dataset
    model = attr.table

    queries = self.queries
    if source != target
      queries = Relation.from_pair(source, target).table.convert(queries).values.flatten.uniq
    end

    model.locate(queries || [], node, hierarchy:)
  rescue ApplicationRecord::AttributeNotFound => e
    errors.add(:attribute, e.message)
  rescue ActiveRecord::RecordNotFound
    errors.add(:node, "'#{node}' were not found")
  rescue ApplicationRecord::RelationNotFound => e
    errors.add(:relation, e.message)
  end
end
