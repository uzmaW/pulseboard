defmodule PulseboardCompliance do
  @moduledoc """
  Compliance context for PulseBoard.

  Provides regional data governance, audit trails,
  consent flows, and retention policies.
  """

  alias PulseboardCore.Compliance.CompliancePolicy

  @doc """
  Applies a compliance policy for a tenant.
  """
  @spec apply_policy(map()) :: :ok | {:error, term()}
  def apply_policy(attrs) do
    case CompliancePolicy.new(attrs) do
      {:ok, policy} ->
        :telemetry.execute(
          [:pulseboard, :compliance, :policy_applied],
          %{count: 1},
          %{tenant_id: policy.tenant_id, region: policy.region}
        )

        emit_event(:compliance_policy_applied, policy.tenant_id, nil, %{
          region: policy.region,
          retention_days: policy.retention_days,
          consent_required: policy.consent_required
        })

        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Checks if data retention has exceeded the policy period.
  """
  @spec retention_exceeded?(binary(), DateTime.t()) :: boolean()
  def retention_exceeded?(tenant_id, data_timestamp) do
    # In production, fetch the policy from the database
    # For now, use region defaults
    policy = %CompliancePolicy{
      id: "temp",
      tenant_id: tenant_id,
      region: "global",
      retention_days: 365,
      consent_required: false,
      audit_enabled: true,
      data_classification: :confidential,
      created_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    CompliancePolicy.retention_exceeded?(policy, data_timestamp)
  end

  @doc """
  Returns region-specific default settings.
  """
  @spec region_defaults(binary()) :: map()
  def region_defaults(region) do
    CompliancePolicy.region_defaults(region)
  end

  @doc """
  Logs an audit event.
  """
  @spec log_audit(binary(), binary(), binary(), map()) :: :ok
  def log_audit(tenant_id, user_id, action, details \\ %{}) do
    :telemetry.execute(
      [:pulseboard, :compliance, :audit_logged],
      %{count: 1},
      %{tenant_id: tenant_id, user_id: user_id, action: action}
    )

    emit_event(:audit_logged, tenant_id, user_id, Map.put(details, :action, action))
  end

  defp emit_event(type, tenant_id, user_id, payload) do
    PulseboardCore.Event.Bus.publish(
      PulseboardCore.Event.new(type, tenant_id, user_id, payload)
    )
  end
end
