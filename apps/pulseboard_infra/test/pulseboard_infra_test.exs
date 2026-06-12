defmodule PulseboardInfraTest do
  use ExUnit.Case

  test "module is defined" do
    assert Code.ensure_loaded?(PulseboardInfra)
  end
end
