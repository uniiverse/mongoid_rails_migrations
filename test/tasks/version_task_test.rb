require_relative './task_test_base'

module Mongoid
  class VersionTaskTest < TaskTestBase
    def test_database_version
      Mongoid::Migrator.migrations_path = [MIGRATIONS_ROOT + "/valid"]
      assert_output("0\n") { invoke("mongoid:version") }
      invoke("mongoid:migrate")
      assert_output("20100513063902\n") { invoke("mongoid:version") }
      invoke("mongoid:drop")
      assert_output("0\n") { invoke("mongoid:version") }
    end

    def test_multidatabase_version
      Mongoid::Migrator.migrations_path = [MIGRATIONS_ROOT + "/multi_shards"]
      assert_output("0\n") { invoke("mongoid:version") }
      invoke("mongoid:migrate")
      assert_output("20210210125800\n") { invoke("mongoid:version") }
      invoke("mongoid:drop")
      assert_output("0\n") { invoke("mongoid:version") }
    end

    def test_multidatabase_version_with_target_client_and_rollback
      Mongoid::Migrator.migrations_path = [MIGRATIONS_ROOT + "/multi_shards"]
      with_env("MONGOID_CLIENT_NAME" => "shard1") do
        assert_output("0\n") { invoke("mongoid:version") }
        invoke("mongoid:migrate")
        assert_output("20210210125532\n") { invoke("mongoid:version") }
        invoke("mongoid:rollback")
        assert_output("20210210124656\n") { invoke("mongoid:version") }
        invoke("mongoid:rollback")
        assert_output("0\n") { invoke("mongoid:version") }
      end
    end
  end
end
