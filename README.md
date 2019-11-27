# Snapshot feature using PaperTrail

This is a sample Rails application implementing Paper Trail gem for auditing and versioning purposes. Using data from the audit trail, this app provides an interface to retreive snapshot of ActiveRecord collections based on Postgres capabilities. 

### Building SQL query
```sql
-- filtering projects
(
  SELECT *
  FROM projects
  WHERE projects.updated_at <= '2019-11-11 00:00:00'
);

-- filtering versions
(
  SELECT *
  FROM versions
  WHERE item_type = 'Project'
    AND created_at > '2019-11-11 00:00:00'
);

-- filtering versions (excluding 'create')
(
  SELECT *
  FROM versions
  WHERE item_type = 'Project'
    AND event != 'create'
    AND created_at > '2019-11-11 00:00:00'
);

-- filtering versions (DISTINCT + ORDER BY created_at)
-- https://malisper.me/select-distinct-on-order-by
(
  SELECT DISTINCT ON(item_id) *
  FROM versions
  WHERE item_type = 'Project'
    AND event != 'create'
    AND created_at > '2019-11-11 00:00:00'
  ORDER BY item_id, created_at ASC
);

-- filtering versions (bounded created_at)
-- https://github.com/perangusta/snapshots-with-paper-trail-app/commit/b0a3f9f68b8f409f7cd21c94de834295da92e443#diff-06efbc85d6dcc91f9598cf5cc4364a95
(
  SELECT DISTINCT ON(item_id) *
  FROM versions
  WHERE item_type = 'Project'
    AND event != 'create'
    AND created_at > '2019-11-11 00:00:00'
    AND previous_created_at <= '2019-11-11 00:00:00'
  ORDER BY item_id, created_at ASC
);

-- UNION
(
  SELECT DISTINCT ON(item_id) *
  FROM versions
  WHERE item_type = 'Project'
    AND event != 'create'
    AND created_at > '2019-11-11 00:00:00'
    AND previous_created_at <= '2019-11-11 00:00:00'
  ORDER BY item_id, created_at ASC
)
UNION
(
  SELECT *
  FROM projects
  WHERE projects.updated_at <= '2019-11-11 00:00:00'
);

-- UNION + SELECT
-- https://www.postgresql.org/docs/9.5/functions-json.html
(
  SELECT
    DISTINCT ON(item_id) item_id AS id,
    (object->>'name')            AS name,
    (object->>'start_on')        AS start_on
  FROM versions
  WHERE item_type = 'Project'
    AND event != 'create'
    AND created_at > '2019-11-11 00:00:00'
    AND previous_created_at <= '2019-11-11 00:00:00'
  ORDER BY item_id, created_at ASC
)
UNION
(
  SELECT
    id,
    name,
    start_on
  FROM projects
  WHERE projects.updated_at <= '2019-11-11 00:00:00'
);

-- UNION + SELECT + CAST
(
  SELECT
    DISTINCT ON(item_id) item_id         AS id,
    (object->>'name')::varchar           AS name,
    (object->>'start_on')::timestamp     AS start_on
  FROM versions
  WHERE item_type = 'Project'
    AND event != 'create'
    AND created_at > '2019-11-11 00:00:00'
    AND previous_created_at <= '2019-11-11 00:00:00'
  ORDER BY item_id, created_at ASC
)
UNION
(
  SELECT
    id,
    name,
    start_on
  FROM projects
  WHERE projects.updated_at <= '2019-11-11 00:00:00'
);
```

### From Postgres to Ruby

#### Build SELECT statement for `versions` table

```ruby
# using: 
#   columns_hash and its settings `sql_type`, `array`
#   defined_enums private method
  
versions_select_statement = 
  columns_hash.map do |column_name, column_settings|
    if defined_enums.key?(column_name)
      # enums from String to Integer + fallback on raw value 
      "CASE versions.object->>'#{column_name}' #{defined_enums[column_name].map { |k, v| "WHEN '#{k}' THEN #{v}::integer" }.join(' ')} ELSE (versions.object->>'#{column_name}')::integer END AS #{column_name}"
    elsif column_settings.array
      # arrays casting
      "(ARRAY(SELECT jsonb_array_elements_text((versions.object->'#{column_name}')::jsonb))::#{column_settings.sql_type}[]) AS #{column_name}"
    else
      "(versions.object->>'#{column_name}')::#{column_settings.sql_type} AS #{column_name}"
    end
  end.join(', ')
```

Returns:
```sql
SELECT
  -- standard
  (versions.object->>'id')::bigint AS id,
  (versions.object->>'name')::character varying AS name,
  (versions.object->>'description')::text AS description,
  (versions.object->>'baseline')::numeric AS baseline,
  (versions.object->>'savings')::numeric AS savings,
  (versions.object->>'start_on')::date AS start_on,
  (versions.object->>'end_on')::date AS end_on,
  (versions.object->>'created_at')::timestamp(6) without time zone AS created_at,
  (versions.object->>'updated_at')::timestamp(6) without time zone AS updated_at,
  -- enums
  CASE versions.object->>'state' WHEN 'draft' THEN 1::integer WHEN 'completed' THEN 2::integer WHEN 'deleted' THEN 3::integer ELSE (versions.object->>'state')::integer END AS state,
  CASE versions.object->>'status' WHEN 'planned' THEN 1::integer WHEN 'started' THEN 2::integer WHEN 'completed' THEN 3::integer WHEN 'cancelled' THEN 4::integer ELSE (versions.object->>'status')::integer END AS status,
  -- arrays
  (ARRAY(SELECT jsonb_array_elements_text((versions.object->'tags')::jsonb))::character varying[]) AS tags
```

#### Build SELECT for live records tables:

```ruby
records_select_statement = 
  columns_hash.map do |column_name, column_settings|
    "(#{table_name}.#{column_name})::#{column_settings.sql_type}#{'[]' if column_settings.array} AS #{column_name}"
  end.join(', ')
```

Returns:
```sql
SELECT
  -- standard
  (projects.id)::bigint AS id,
  (projects.name)::character varying AS name,
  (projects.description)::text AS description,
  (projects.baseline)::numeric AS baseline,
  (projects.savings)::numeric AS savings,
  (projects.start_on)::date AS start_on,
  (projects.end_on)::date AS end_on,
  (projects.created_at)::timestamp(6) without time zone AS created_at,
  (projects.updated_at)::timestamp(6) without time zone AS updated_at,
  -- enums
  (projects.state)::integer AS state,
  (projects.status)::integer AS status,
  -- arrays
  (projects.tags)::character varying[] AS tags,
```

### References

* Paper Trail gem  
  https://github.com/paper-trail-gem/paper_trail
* Audited gem  
  https://github.com/collectiveidea/audited
* Timecop  
  https://github.com/travisjeffery/timecop
* SELECT DISTINCT ON … ORDER BY  
  https://malisper.me/select-distinct-on-order-by/
* Postgres JSON operators and functions  
  https://www.postgresql.org/docs/12/functions-json.html
* ActiveRecord::ConnectionAdapters::SchemaCache#columns_hash    
  https://apidock.com/rails/ActiveRecord/ConnectionAdapters/SchemaCache/columns_hash
* ActiveRecord::QueryMethods#from  
  https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-from
* ActiveRecord defined_enums private method  
  https://github.com/rails/rails/blob/master/activerecord/lib/active_record/enum.rb
* The battle for auditing and versioning in Rails — Audited vs Paper Trail  
  https://revs.runtime-revolution.com/the-battle-for-auditing-and-versioning-in-rails-audited-vs-paper-trail-17ad0011ecd9
* Why exactly is data auditing important?  
  http://www.realisedatasystems.com/why-exactly-is-data-auditing-important/
