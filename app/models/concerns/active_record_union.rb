module ActiveRecordUnion
  extend ActiveSupport::Concern

  class_methods do
    def union(*relations, **options)
      alias_name = options[:alias_name] || "t_#{self.table_name}"
      from("(#{relations.map(&:to_sql).join(' UNION ')}) AS \"#{alias_name}\"")
    end
  end
end
