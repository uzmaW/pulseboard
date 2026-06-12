defmodule PulseboardSchedulerTest do
  use ExUnit.Case

  test "schedule_onboarding/1 returns ok with job" do
    attrs = %{name: "Test Tenant", region: "US"}
    assert {:ok, job} = PulseboardScheduler.schedule_onboarding(attrs)
    assert job.tenant_attrs == attrs
  end

  test "schedule_nudge/3 returns ok with job" do
    assert {:ok, job} = PulseboardScheduler.schedule_nudge("user-1", "tenant-1", "Hello")
    assert job.user_id == "user-1"
    assert job.tenant_id == "tenant-1"
    assert job.message == "Hello"
  end

  test "schedule_retention_cleanup/1 returns ok with job" do
    assert {:ok, job} = PulseboardScheduler.schedule_retention_cleanup("tenant-1")
    assert job.tenant_id == "tenant-1"
  end
end
