class AddOrderToAttribute < ActiveRecord::Migration[6.1]
  def change
    add_column :attributes, :order, :string
  end
end
