class CountBreakdown < ApplicationInteraction
  string :attribute
  string :node, default: nil
  string :mode, default: nil

  def execute
    Rails.cache.fetch(cache_key) do
      attr = Attribute.from_api(attribute)
      attr.table.breakdown(node, attr.order)
    end
  rescue ActiveRecord::RecordNotFound
    errors.add(:attribute, 'does not exist')
  rescue ArgumentError => e
    errors.add(:mode, 'is invalid')
  end

  private

  def cache_key
    [self.class.name, attribute, node, mode].map(&:to_s).join(':')
  end
end
