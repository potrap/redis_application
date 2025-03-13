defmodule RedisApplicationWeb.RedisDataPage do
  @moduledoc """

  """
  use RedisApplicationWeb, :surface_live_view
  alias RedisApplication.KeyValuePairs
  alias Moon.Design.Table.Column
  alias Moon.Design.{Table, Button, Modal, Form}
  alias Moon.Design.Form.{Field, Input}

  data(create_modal_is_open, :boolean, default: false)
  data(update_modal_is_open, :boolean, default: false)
  data(delete_modal_is_open, :boolean, default: false)
  data(form, :any, default: to_form(%{key: "", value: ""}))
  data(key_error, :string, default: "")
  data(value_error, :string, default: "")
  data(selected_key, :string, default: "")
  data(selected_value, :string, default: "")

  def mount(_, _, socket) do
    conn = connect_to_redis()

    {
      :ok,
      assign(
        socket,
        conn: conn,
        redis_data: KeyValuePairs.fetch_pairs(conn)
      )
    }
  end

  def handle_event("open_create_modal", _, socket) do
    Modal.open("create_modal")

    {
      :noreply,
      assign(socket,
        create_modal_is_open: true
      )
    }
  end

  def handle_event("open_update_modal", %{"value" => key}, socket) do
    Modal.open("update_modal")

    {:ok, value} = KeyValuePairs.get_value(socket.assigns.conn, key)

    {
      :noreply,
      assign(socket,
        selected_key: key,
        selected_value: value,
        update_modal_is_open: true
      )
    }
  end

  def handle_event("open_delete_modal", %{"value" => key}, socket) do
    Modal.open("delete_modal")

    {
      :noreply,
      assign(socket,
        delete_modal_is_open: true,
        selected_key: key
      )
    }
  end

  def handle_event("close_create_modal", _, socket) do
    Modal.close("create_modal")

    {
      :noreply,
      assign(socket,
        create_modal_is_open: false
      )
    }
  end

  def handle_event("close_update_modal", _, socket) do
    Modal.close("update_modal")

    {
      :noreply,
      assign(socket,
        selected_key: "",
        selected_value: "",
        update_modal_is_open: false
      )
    }
  end

  def handle_event("close_delete_modal", _, socket) do
    Modal.close("delete_modal")

    {
      :noreply,
      assign(socket,
        selected_key: "",
        delete_modal_is_open: false
      )
    }
  end

  def handle_event("create_key_value_pair", form_data, socket) do
    KeyValuePairs.set_key_value_pair(
      socket.assigns.conn,
      form_data["key"],
      form_data["value"]
    )

    {
      :noreply,
      assign(socket,
        create_modal_is_open: false,
        update_modal_is_open: false,
        selected_key: "",
        selected_value: "",
        redis_data: KeyValuePairs.fetch_pairs(socket.assigns.conn)
      )
    }
  end

  def handle_event("delete_key_value_pair", %{"value" => key}, socket) do
    KeyValuePairs.delete_key_value_pair(socket.assigns.conn, key)

    {
      :noreply,
      assign(socket,
        delete_modal_is_open: false,
        selected_key: "",
        redis_data: KeyValuePairs.fetch_pairs(socket.assigns.conn)
      )
    }
  end

  def handle_event("validate_create", %{"key" => key, "value" => value} = key_value_pair, socket) do
    {key_error, value_error} = validate_key_value(key, value, socket.assigns.conn)

    socket =
      assign(socket,
        key_error: key_error,
        value_error: value_error,
        form: to_form(key_value_pair)
      )

    {:noreply, socket}
  end

  def handle_event("validate_update", %{"value" => value}, socket) do
    value_error = validate_value(value)

    socket =
      assign(socket,
        value_error: value_error,
        selected_value: value,
        form: to_form(%{"value" => value})
      )

    {:noreply, socket}
  end

  defp validate_key_value(key, value, conn) do
    key_error = validate_key(key, conn)
    value_error = validate_value(value)

    {key_error, value_error}
  end

  defp validate_key(key, conn) do
    cond do
      is_nil(key) or key == "" -> "Key is required"
      KeyValuePairs.key_exists?(key, conn) -> "Key must be unique"
      true -> ""
    end
  end

  defp validate_value(value) do
    if is_nil(value) or value == "" do
      "Value is required"
    else
      ""
    end
  end

  defp connect_to_redis do
    config = Application.get_env(:redis_application, :redis_local)

    if config == nil do
      connect_to_redis_test()
    else
      {:ok, conn} = Redix.start_link(host: config[:host], port: config[:port])
      conn
    end
  end

  defp connect_to_redis_test do
    {:ok, conn} = Redix.start_link(host: "localhost", port: 6380)

    conn
  end
end
