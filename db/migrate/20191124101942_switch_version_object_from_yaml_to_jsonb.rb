class SwitchVersionObjectFromYamlToJsonb < ActiveRecord::Migration[6.0]
  def change
    # Create temporary columns to convert YAML to jsonb
    add_column :versions, :new_object, :jsonb
    add_column :versions, :new_object_changes, :jsonb

    reversible do |direction|
      direction.up do
        PaperTrail::Version.where.not(object: nil).find_each do |version|
          attributes = { new_object: YAML.load(version.object) }

          if version.object_changes
            attributes[:new_object_changes] = YAML.load(version.object_changes)
          end

          version.update_columns(attributes)
        end
      end

      direction.down do
        PaperTrail::Version.where.not(new_object: nil).find_each do |version|
          attributes = { object: YAML.dump(version.new_object) }

          if version.new_object_changes
            attributes[:object_changes] = YAML.dump(version.new_object_changes)
          end

          version.update_columns(attributes)
        end
      end
    end

    # Switch columns
    remove_column :versions, :object, :text
    remove_column :versions, :object_changes, :text
    rename_column :versions, :new_object, :object
    rename_column :versions, :new_object_changes, :object_changes
  end
end
