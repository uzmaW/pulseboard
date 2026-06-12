defmodule PulseboardComplianceTest do
  use ExUnit.Case

  test "apply_policy/1 returns ok" do
    attrs = %{
      tenant_id: "tenant-1",
      region: "EU",
      retention_days: 90,
      consent_required: true
    }

    assert :ok = PulseboardCompliance.apply_policy(attrs)
  end

  test "region_defaults/1 returns region defaults" do
    defaults = PulseboardCompliance.region_defaults("EU")
    assert defaults.retention_days == 90
    assert defaults.consent_required == true
  end

  test "log_audit/4 returns ok" do
    assert :ok = PulseboardCompliance.log_audit("tenant-1", "user-1", "viewed_profile")
  end
end
