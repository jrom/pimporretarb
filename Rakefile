# By Jordi Romero

task :environment do
  require 'config'
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migration")
  end

  desc "Load seed data: hello world"
  task(:seed => :migrate) do
    require 'db/seed'
  end
end
