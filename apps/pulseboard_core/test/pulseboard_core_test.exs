defmodule PulseboardCoreTest do
  use ExUnit.Case

  test "version/0 returns the application version" do
    assert PulseboardCore.version() == "0.1.0"
  end
end
