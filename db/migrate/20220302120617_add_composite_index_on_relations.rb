class AddCompositeIndexOnRelations < ActiveRecord::Migration[6.1]
  def change
    remove_index :relations, column: :db1
    remove_index :relations, column: :entry1
    remove_index :relations, column: :db2
    remove_index :relations, column: :entry2
    add_index :relations, %i[entry1 db1 db2]
    add_index :relations, %i[entry2 db2 db1]
  end
end
