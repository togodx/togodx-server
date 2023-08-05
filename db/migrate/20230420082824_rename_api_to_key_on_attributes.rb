class RenameApiToKeyOnAttributes < ActiveRecord::Migration[6.1]
  def change
    rename_column :attributes, :api, :key
  end
end
