defmodule PulseboardPlugins do
  @moduledoc """
  Plugin architecture for tenant workflows.

  Provides a framework for integrating external services
  like Jira, Notion, and Slack with tenant workflows.
  """

  @type plugin :: module()
  @type config :: map()

  @doc """
  Lists all available plugins.
  """
  @spec available() :: [plugin()]
  def available do
    [
      PulseboardPlugins.Jira,
      PulseboardPlugins.Notion,
      PulseboardPlugins.Slack
    ]
  end

  @doc """
  Initializes a plugin with the given configuration.
  """
  @spec init(plugin(), config()) :: {:ok, plugin()} | {:error, term()}
  def init(plugin, config) do
    if function_exported?(plugin, :init, 1) do
      plugin.init(config)
    else
      {:ok, plugin}
    end
  end

  @doc """
  Executes a plugin action.
  """
  @spec execute(plugin(), atom(), map()) :: {:ok, term()} | {:error, term()}
  def execute(plugin, action, params) do
    plugin.execute(action, params)
  rescue
    UndefinedFunctionError -> {:error, :not_implemented}
  end
end
