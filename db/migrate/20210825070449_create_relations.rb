class CreateRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :relations do |t|
      t.string :db1, null: false, index: true
      t.string :entry1, null: false, index: true
      t.string :db2, null: false, index: true
      t.string :entry2, null: false, index: true
    end
  end
end
