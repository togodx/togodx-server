class AddBinToDistribution < ActiveRecord::Migration[6.1]
  def change
    add_column :distributions, :bin_id, :string
    add_column :distributions, :bin_label, :string
  end
end
