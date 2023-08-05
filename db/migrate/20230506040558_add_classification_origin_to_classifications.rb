class AddClassificationOriginToClassifications < ActiveRecord::Migration[6.1]
  def change
    add_column :classifications, :classification_origin, :string, index: true
  end
end
