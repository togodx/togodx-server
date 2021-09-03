class CreateProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :properties do |t|
      t.string  :db, null: false, index: true
      t.string  :entry, null: false, index: true
      t.string  :key, index: true
      t.string  :value
    end
  end
end
