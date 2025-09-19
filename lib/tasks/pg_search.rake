namespace :pg_search do
  desc "Rebuild pg_search multisearch index for key models"
  task rebuild_index: :environment do
    models = [Army, Unit, Clock, Faction, Family, Recipe, Location]

    puts "Cleaning pg_search_documents..."
    PgSearch::Document.delete_all

    models.each do |model|
      puts "Reindexing #{model.name}..."
      PgSearch::Multisearch.rebuild(model, clean_up: true)
    end

    puts "pg_search index rebuild complete."
  end
end

# Call bundle exec rake pg_search:rebuild_index to rebuild
