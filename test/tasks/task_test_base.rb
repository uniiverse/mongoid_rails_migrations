require_relative '../helper'

load 'lib/mongoid_rails_migrations/mongoid_ext/railties/database.rake'

module Mongoid
  class TaskTestBase < Minitest::Test #:nodoc:
    def setup
      invoke("mongoid:drop")
      with_env("MONGOID_CLIENT_NAME" => "shard1") do
        invoke("mongoid:drop")
      end
    end

    def teardown
      Mongoid::Migrator.migrations_path = ["db/mongoid/migrate"]
    end
  end
end
