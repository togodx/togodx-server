class CreateDistributions < ActiveRecord::Migration[6.1]
  def change
    create_table :distributions do |t|
      t.string :distribution, null: false, index: true
      t.string :distribution_label
      t.float :distribution_value, null: false, index: true
    end
  end
end
