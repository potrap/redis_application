defmodule RedisApplication.KeyValuePairsTest do
  use ExUnit.Case, async: true

  alias RedisApplication.KeyValuePairs

  setup do
    {:ok, redis_conn} = Redix.start_link(host: "localhost", port: 6380)
    %{conn: redis_conn}
  end

  test "set and get key value pair", %{conn: conn} do
    assert {:ok, "OK"} = KeyValuePairs.set_key_value_pair(conn, "test_set_key", "test_set_value")
    assert {:ok, "test_set_value"} = KeyValuePairs.get_value(conn, "test_set_key")
  end

  test "get non-existent key value pair", %{conn: conn} do
    assert {:ok, nil} = KeyValuePairs.get_value(conn, "non_existent_key")
  end

  test "set and delete key value pair", %{conn: conn} do
    assert {:ok, "OK"} =
             KeyValuePairs.set_key_value_pair(conn, "test_delete_key", "test_delete_value")

    assert {:ok, "test_delete_value"} = KeyValuePairs.get_value(conn, "test_delete_key")
    assert {:ok, 1} = KeyValuePairs.delete_key_value_pair(conn, "test_delete_key")
    assert {:ok, nil} = KeyValuePairs.get_value(conn, "test_delete_key")
  end

  test "fetch pairs", %{conn: conn} do
    assert {:ok, "OK"} =
             KeyValuePairs.set_key_value_pair(conn, "test_fetch_key", "test_fetch_value")

    assert true = KeyValuePairs.fetch_pairs(conn) |> length > 1
  end

  test "key exists", %{conn: conn} do
    assert true = KeyValuePairs.key_exists?("test_set_key", conn)
  end
end
