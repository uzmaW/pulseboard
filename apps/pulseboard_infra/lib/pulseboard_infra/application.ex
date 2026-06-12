defmodule PulseboardInfra.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PulseboardInfra.Repo,
      {Task.Supervisor, name: PulseboardInfra.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: PulseboardInfra.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
