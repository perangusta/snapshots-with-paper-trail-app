module Versionable
  def self.included(base)
    base.class_eval do
      # Provide models with a common entry point for paper_trail
      def self.configure_paper_trail
        has_paper_trail meta: {
          item_name:           :paper_trail_item_name,
          previous_created_at: :paper_trail_previous_created_at
        }
      end

      # Scope to build a snapshot at the given timestamp
      def self.snapshot_at(datetime)
        versions_select_statement = columns_hash.map do |column_name, column_settings|
          if defined_enums.key?(column_name.to_s)
            "CASE versions.object->>'#{column_name}' #{defined_enums[column_name.to_s].map { |k, v| "WHEN '#{k}' THEN #{v}::integer" }.join(' ')} ELSE (versions.object->>'#{column_name}')::integer END AS #{column_name}"
          else
            "(versions.object->>'#{column_name}')::#{column_settings.sql_type} AS #{column_name}"
          end
        end.join(', ')

        original_select_statement = columns_hash.map do |column_name, column_settings|
          "(#{table_name}.#{column_name})::#{column_settings.sql_type} AS #{column_name}"
        end.join(', ')

        versions_collection_statement = <<~SQL.squish
          SELECT DISTINCT ON(item_id) #{versions_select_statement}
          FROM versions
          WHERE versions.item_type = '#{model_name.name}'
            AND versions.event != 'create'
            AND versions.previous_created_at <= '#{datetime.to_s(:db)}'
            AND versions.created_at > '#{datetime.to_s(:db)}'
          ORDER BY versions.item_id, versions.created_at ASC
        SQL

        original_collection_statement = all.
          where("#{table_name}.updated_at <= ?", datetime).
          select(original_select_statement).
          to_sql

        union_statement = <<~SQL.squish
          (
            (#{versions_collection_statement})
            UNION
            (#{original_collection_statement})
          ) AS #{table_name}
        SQL

        from(union_statement)
      end
    end
  end

  def paper_trail_item_name
    to_s
  end

  def paper_trail_previous_created_at
    updated_at_before_last_save || versions.select(:created_at).last&.created_at
  end
end
