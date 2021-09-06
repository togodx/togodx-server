Rails.configuration.to_prepare do
  Attribute.all.each do |attribute|
    const_name = "Table#{attribute.id}"

    # undefine constant if it already exists (on reload, etc)
    Object.send(:remove_const, const_name) if Object.const_defined? const_name

    klass = Class.new(attribute.datamodel.constantize) do |klass|
      klass.table_name = const_name.underscore
    end

    Object.const_set const_name, klass
  end
rescue ActiveRecord::StatementInvalid
  # attributes table not found
end
