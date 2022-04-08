class CountBreakdown < ApplicationInteraction
  string :attribute
  string :node, default: nil
  string :order, default: nil

  def execute
    Rails.cache.fetch(cache_key) do
      attr = Attribute.from_api(attribute)
      attr.table.breakdown(node, order)
    end
  rescue ApplicationRecord::AttributeNotFound => e
    errors.add(:attribute, e.message)
  rescue ArgumentError => e
    errors.add(:order, "'#{order}' is invalid")
  end

  private

  def cache_key
    [self.class.name, attribute, node, order].map(&:to_s).join(':')
  end
end
