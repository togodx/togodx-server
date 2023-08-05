class SplitRelationsIntoEachPairs < ActiveRecord::Migration[6.1]
  def change
    remove_index :relations, %i[entry1 db1 db2]
    remove_index :relations, %i[entry2 db2 db1]

    remove_column :relations, :db1, :string
    remove_column :relations, :entry1, :string
    remove_column :relations, :db2, :string
    remove_column :relations, :entry2, :string

    add_column :relations, :source, :string
    add_column :relations, :target, :string

    add_index :relations, %i[source target], unique: true

    create_table :relation do |t|
      t.string :source, null: false, index: true
      t.string :target, null: false, index: true
    end
    add_index :relation, %i[source target], unique: true
  end
end
