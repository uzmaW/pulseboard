defmodule PulseboardPluginsTest do
  use ExUnit.Case

  test "available/0 returns list of plugins" do
    plugins = PulseboardPlugins.available()
    assert is_list(plugins)
    assert length(plugins) == 3
  end

  test "init/2 initializes a plugin" do
    config = %{
      base_url: "https://jira.example.com",
      api_token: "token",
      project_key: "PROJ"
    }

    assert {:ok, PulseboardPlugins.Jira} = PulseboardPlugins.init(PulseboardPlugins.Jira, config)
  end

  test "execute/3 executes a plugin action" do
    params = %{issue_key: "PROJ-123"}
    assert {:ok, result} = PulseboardPlugins.execute(PulseboardPlugins.Jira, :get_issue, params)
    assert result.issue_key == "PROJ-123"
  end
end
