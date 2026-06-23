namespace :mongoid do
  unless Rake::Task.task_defined?("mongoid:drop")
    desc 'Drops all the collections for the database for the current Rails.env'
    task :drop => :environment do
      # Mongoid 7: Mongoid.master was removed; drop non-system collections via the default client.
      Mongoid::Migration.connection.database.collections.each do |col|
        col.drop unless col.name.start_with?('system.')
      end
    end
  end

  unless Rake::Task.task_defined?("mongoid:seed")
    # if another ORM has defined mongoid:seed, don't run it twice.
    desc 'Load the seed data from db/seeds.rb'
    task :seed => :environment do
      seed_file = File.join(Rails.application.root, 'db', 'seeds.rb')
      load(seed_file) if File.exist?(seed_file)
    end
  end

  unless Rake::Task.task_defined?("mongoid:setup")
    desc 'Create the database, and initialize with the seed data'
    task :setup => [ 'mongoid:create', 'mongoid:seed' ]
  end

  unless Rake::Task.task_defined?("mongoid:reseed")
    desc 'Delete data and seed'
    task :reseed => [ 'mongoid:drop', 'mongoid:seed' ]
  end

  unless Rake::Task.task_defined?("mongoid:create")
    task :create => :environment do
      # noop
    end
  end

  desc 'Current database version'
  task :version => :environment do
    puts Mongoid::Migrator.current_version.to_s
  end

  desc "Migrate the database through scripts in db/mongoid/migrate. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate => :environment do
    Mongoid::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    Mongoid::Migrator.migrate(Mongoid::Migrator.migrations_path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  namespace :migrate do
    desc 'Rollback the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
    task :redo => :environment do
      if ENV["VERSION"]
        Rake::Task["mongoid:migrate:down"].invoke
        Rake::Task["mongoid:migrate:up"].invoke
      else
        Rake::Task["mongoid:rollback"].invoke
        Rake::Task["mongoid:migrate"].invoke
      end
    end

    desc 'Resets your database using your migrations for the current environment'
    task :reset => ["mongoid:drop", "mongoid:create", "mongoid:migrate"]

    desc 'Runs the "up" for a given migration VERSION.'
    task :up => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      Mongoid::Migrator.run(:up, Mongoid::Migrator.migrations_path, version)
    end

    desc 'Runs the "down" for a given migration VERSION.'
    task :down => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      Mongoid::Migrator.run(:down, Mongoid::Migrator.migrations_path, version)
    end

    desc 'Display status of migrations'
    task :status => :environment do
      Mongoid::Migrator.status(Mongoid::Migrator.migrations_path)
    end
  end

  desc 'Rolls the database back to the previous migration. Specify the number of steps with STEP=n'
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    Mongoid::Migrator.rollback(Mongoid::Migrator.migrations_path, step)
  end

  desc 'Rolls the database back to the specified VERSION'
  task :rollback_to => :environment do
    version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    raise "VERSION is required" unless version
    Mongoid::Migrator.rollback_to(Mongoid::Migrator.migrations_path, version)
  end

  namespace :schema do
    task :load do
      # noop
    end
  end

  namespace :test do
    task :prepare do
      # Stub out for MongoDB
    end
  end
end
