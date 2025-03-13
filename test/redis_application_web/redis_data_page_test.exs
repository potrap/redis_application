defmodule RedisApplication.RedisDataPageTest do
  use RedisApplicationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenix.ConnTest

  setup do
    {:ok, redis_conn} = Redix.start_link(host: "localhost", port: 6380)
    %{redis_conn: redis_conn}
  end

  test "renders Redis page with correct content", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ "Create Key-Value"
    assert html =~ "Delete"
    assert html =~ "Update value"
    assert html =~ "Key"
    assert html =~ "Value"
  end

  test "open the create modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button", "Create Key-Value")
    |> render_click()

    assert render(view) =~ "Create new Key-Value pair"
  end

  test "open the update modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button[value='test_set_key']", "Update value")
    |> render_click()

    assert render(view) =~ "Update value"
  end

  test "open the delete modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button[value='test_set_key']", "Delete")
    |> render_click()

    assert render(view) =~ "Are you sure you want to delete"
  end

  test "create a new pair and show it on the page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button", "Create Key-Value")
    |> render_click()

    view
    |> form("#create_modal form", %{key: "new_key", value: "new_value"})
    |> render_submit()

    assert render(view) =~ "new_key"
    assert render(view) =~ "new_value"
  end

  test "delete a pair and remove it from the page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "new_key"
    assert render(view) =~ "new_value"

    view
    |> element("button[value='new_key']", "Delete")
    |> render_click()

    view
    |> element("div#delete_modal button[value='new_key']", "Delete")
    |> render_click()

    refute render(view) =~ "new_key"
    refute render(view) =~ "new_value"
  end

  test "update a new pair and show it on the page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button", "Create Key-Value")
    |> render_click()

    view
    |> form("#create_modal form", %{key: "key_t", value: "value_t"})
    |> render_submit()

    assert render(view) =~ "key_t"
    assert render(view) =~ "value_t"

    view
    |> element("button[value='key_t']", "Update value")
    |> render_click()

    view
    |> form("#update_modal form", %{key: "key_t", value: "updated_value_t"})
    |> render_submit()

    assert render(view) =~ "key_t"
    assert render(view) =~ "updated_value_t"
  end
end
