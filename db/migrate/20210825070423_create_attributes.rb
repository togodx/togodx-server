class CreateAttributes < ActiveRecord::Migration[6.1]
  def change
    create_table :attributes do |t|
      t.string :api, null: false, index: { unique: true }
      t.string :dataset, null: false
      t.string :datamodel, null: false
    end
  end
end
