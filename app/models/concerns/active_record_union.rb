module ActiveRecordUnion
  extend ActiveSupport::Concern

  class_methods do
    def union(*relations)
      from("(#{relations.map(&:to_sql).join(' UNION ')})")
    end
  end
end
