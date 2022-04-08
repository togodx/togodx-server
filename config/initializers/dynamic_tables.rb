Rails.configuration.to_prepare do
  Attribute.all.each do |attribute|
    const_name = "Table#{attribute.id}"

    # undefine constant if it already exists (on reload, etc)
    Object.send(:remove_const, const_name) if Object.const_defined? const_name

    eval <<~RUBY
      class #{const_name} < ApplicationRecord
        acts_as_nested_set counter_cache: :count
        self.table_name = "#{const_name.underscore}"
        include #{attribute.to_model_class.name}::Base
      end
    RUBY
  end

  Relation.all.each do |relation|
    const_name = "Relation#{relation.id}"
    Object.send(:remove_const, const_name) if Object.const_defined? const_name
    eval <<~RUBY
      class #{const_name} < ApplicationRecord
        self.table_name = "#{const_name.underscore}"
        include Relation::Base
      end
    RUBY
  end
  
rescue ActiveRecord::StatementInvalid
  # attributes table not found
end
