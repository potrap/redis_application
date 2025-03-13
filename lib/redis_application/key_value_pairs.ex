defmodule RedisApplication.KeyValuePairs do
  def key_exists?(key, conn) do
    case Redix.command(conn, ["EXISTS", key]) do
      {:ok, 1} -> true
      {:ok, 0} -> false
      {:error, _} -> false
    end
  end

  def set_key_value_pair(conn, key, value) do
    Redix.command(conn, ["SET", key, value])
  end

  def delete_key_value_pair(conn, key) do
    Redix.command(conn, ["DEL", key])
  end

  def get_value(conn, key) do
    Redix.command(conn, ["GET", key])
  end

  def fetch_pairs(conn) do
    {:ok, keys} = Redix.command(conn, ["KEYS", "*"])

    keys
    |> Enum.map(fn key ->
      {:ok, value} = Redix.command(conn, ["GET", key])
      %{key: key, value: value}
    end)
  end
end
