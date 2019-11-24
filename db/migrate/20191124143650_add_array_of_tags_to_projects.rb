class AddArrayOfTagsToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :tags, :string, array: true
  end
end
