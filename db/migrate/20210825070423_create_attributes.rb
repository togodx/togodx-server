class CreateAttributes < ActiveRecord::Migration[6.1]
  def change
    create_table :attributes do |t|
      t.string :api, null: false
      t.string :label
      t.string :dataset, null: false
      t.string :datamodel, null: false
      t.string :original_api
      t.string :cache_api
    end
  end
end
