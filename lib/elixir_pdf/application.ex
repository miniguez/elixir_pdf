defmodule ElixirPdf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirPdfWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:elixir_pdf, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirPdf.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElixirPdf.Finch},
      # Start a worker by calling: ElixirPdf.Worker.start_link(arg)
      # {ElixirPdf.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirPdfWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirPdf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirPdfWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
