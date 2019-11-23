class AddCachedItemNameToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :item_name, :string
  end
end
