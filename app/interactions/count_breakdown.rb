class CountBreakdown < ApplicationInteraction
  string :attribute
  string :node, default: nil
  string :order, default: nil
  boolean :hierarchy, default: false

  def execute
    Rails.cache.fetch(cache_key) do
      attr = Attribute.from_key(attribute)
      attr.table.breakdown(node, order, hierarchy:)
    end
  rescue ApplicationRecord::AttributeNotFound => e
    errors.add(:attribute, e.message)
  rescue ActiveRecord::RecordNotFound
    errors.add(:node, "'#{node}' were not found")
  rescue ArgumentError
    errors.add(:order, "'#{order}' is invalid")
  end

  private

  def cache_key
    [self.class.name, attribute, node, order, hierarchy].map(&:to_s).join(':')
  end
end
