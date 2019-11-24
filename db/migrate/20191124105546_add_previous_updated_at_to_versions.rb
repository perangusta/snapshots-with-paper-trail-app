class AddPreviousUpdatedAtToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :previous_created_at, :datetime

    reversible do |direction|
      direction.up do
        ActiveRecord::Base.connection.execute <<~SQL
          UPDATE versions
          SET 
            previous_created_at = (
              SELECT
                DISTINCT ON(item_type, item_id) previous_versions.created_at
              FROM versions AS previous_versions
              WHERE 
                versions.item_type = previous_versions.item_type 
                AND versions.item_id = previous_versions.item_id
                AND versions.created_at > previous_versions.created_at
              ORDER BY previous_versions.item_type, previous_versions.item_id, previous_versions.created_at DESC
            )
        SQL
      end
    end
  end
end
