class CreatePgSearchDocuments < ActiveRecord::Migration[7.0]
  def up
    say_with_time("Creating table for pg_search multisearch") do
      execute <<-SQL
        CREATE TABLE pg_search_documents (
          id SERIAL PRIMARY KEY,
          content TEXT,
          app_name TEXT DEFAULT 'valar',  -- Set default value for app_name
          searchable_type VARCHAR(255),
          searchable_id INTEGER,
          created_at TIMESTAMP NOT NULL,
          updated_at TIMESTAMP NOT NULL
        );
      SQL

      # Add index on searchable_type and searchable_id for polymorphic association
      execute <<-SQL
        CREATE INDEX index_pg_search_documents_on_searchable_type_and_searchable_id
        ON pg_search_documents (searchable_type, searchable_id);
      SQL
    end
  end

  def down
    say_with_time("Dropping table for pg_search multisearch") do
      execute "DROP TABLE IF EXISTS pg_search_documents;"
    end
  end
end
