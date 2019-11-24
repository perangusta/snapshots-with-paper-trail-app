class AddIpAndUserAgentToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :ip, :string
    add_column :versions, :user_agent, :string
  end
end
