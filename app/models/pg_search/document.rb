module PgSearch
  class Document < ApplicationRecord
    self.table_name = 'valar_pg_search_documents'
  end
end

# This is needed as tables have a prefix
