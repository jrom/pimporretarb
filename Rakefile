# By Jordi Romero

task :environment do
  require 'active_record'
  require 'config'
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migration")
  end

  desc "Load seed data: hello world"
  task(:seed => :migrate) do
    require 'lib/models'
    require 'db/seed'
  end
end
