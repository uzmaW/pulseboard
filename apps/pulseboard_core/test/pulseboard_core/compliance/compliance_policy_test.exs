defmodule PulseboardCore.Compliance.CompliancePolicyTest do
  use ExUnit.Case

  alias PulseboardCore.Compliance.CompliancePolicy

  describe "new/1" do
    test "creates a new compliance policy" do
      attrs = %{
        tenant_id: "tenant-1",
        region: "EU",
        retention_days: 90,
        consent_required: true
      }

      assert {:ok, %CompliancePolicy{} = policy} = CompliancePolicy.new(attrs)
      assert policy.tenant_id == "tenant-1"
      assert policy.region == "EU"
      assert policy.retention_days == 90
      assert policy.consent_required == true
    end

    test "uses default values" do
      attrs = %{tenant_id: "tenant-1", region: "US"}
      assert {:ok, policy} = CompliancePolicy.new(attrs)
      assert policy.retention_days == 365
      assert policy.consent_required == false
    end
  end

  describe "retention_exceeded?/2" do
    test "returns true when retention exceeded" do
      {:ok, policy} = CompliancePolicy.new(%{
        tenant_id: "tenant-1",
        region: "EU",
        retention_days: 30
      })

      old_date = DateTime.add(DateTime.utc_now(), -60, :day)
      assert CompliancePolicy.retention_exceeded?(policy, old_date)
    end

    test "returns false when within retention" do
      {:ok, policy} = CompliancePolicy.new(%{
        tenant_id: "tenant-1",
        region: "US",
        retention_days: 365
      })

      recent_date = DateTime.add(DateTime.utc_now(), -30, :day)
      refute CompliancePolicy.retention_exceeded?(policy, recent_date)
    end
  end

  describe "region_defaults/1" do
    test "returns EU defaults" do
      defaults = CompliancePolicy.region_defaults("EU")
      assert defaults.retention_days == 90
      assert defaults.consent_required == true
    end

    test "returns US defaults" do
      defaults = CompliancePolicy.region_defaults("US")
      assert defaults.retention_days == 365
      assert defaults.consent_required == false
    end
  end
end
