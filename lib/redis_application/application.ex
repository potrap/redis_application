defmodule RedisApplication.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RedisApplicationWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:redis_application, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RedisApplication.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RedisApplication.Finch},
      {Redix, name: :redix},
      # Start a worker by calling: RedisApplication.Worker.start_link(arg)
      # {RedisApplication.Worker, arg},
      # Start to serve requests, typically the last entry
      RedisApplicationWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RedisApplication.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RedisApplicationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
