class CreateClassifications < ActiveRecord::Migration[6.1]
  def change
    create_table :classifications do |t|
      t.string :classification, null: false, index: true
      t.string :classification_label
      t.string :classification_parent
      t.boolean :leaf, index: true
      t.integer :parent_id, index: true
      t.integer :lft, null: false, default: 0, index: true
      t.integer :rgt, null: false, default: 0, index: true
      t.integer :count, null: false, default: 0
    end
  end
end
