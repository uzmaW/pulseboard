defmodule PulseboardWeb.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PulseboardWeb.Telemetry,
      PulseboardWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: PulseboardWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    PulseboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
