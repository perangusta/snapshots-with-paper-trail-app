class AddStatusToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :status, :integer

    reversible do |direction|
      direction.up do
        Project.update_all(status: :planned)
      end
    end
  end
end
