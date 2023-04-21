class AddHierarchyFlagToAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :attributes, :hierarchy, :boolean
  end
end
