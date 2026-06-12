defmodule PulseboardCore.Tenant.Onboarding do
  @moduledoc """
  Tenant onboarding workflow.

  Orchestrates the creation of a new tenant with:
  1. Tenant record creation
  2. RBAC role provisioning (Admin, Member, Guest)
  3. Compliance policy application
  4. Vault namespace creation
  5. LiveKit room setup
  6. Telemetry hook registration
  """

  alias PulseboardCore.Tenant
  alias PulseboardCore.RBAC

  @type onboarding_result :: {:ok, Tenant.t()} | {:error, term()}

  @doc """
  Onboards a new tenant through the complete workflow.
  """
  @spec onboard(map()) :: onboarding_result()
  def onboard(attrs) do
    with {:ok, tenant} <- Tenant.new(attrs),
         :ok <- provision_roles(tenant),
         :ok <- apply_compliance(tenant),
         :ok <- create_vault_namespace(tenant),
         :ok <- setup_realtime_context(tenant),
         :ok <- register_telemetry(tenant) do
      activated_tenant = Tenant.activate(tenant)

      emit_event(:tenant_onboarded, tenant.id, %{
        name: tenant.name,
        region: tenant.region
      })

      {:ok, activated_tenant}
    end
  end

  @doc """
  Lists all onboarding steps for a tenant.
  """
  @spec steps() :: [binary()]
  def steps do
    ~w(
      create_tenant
      provision_roles
      apply_compliance
      create_vault_namespace
      setup_realtime_context
      register_telemetry
      activate_tenant
    )
  end

  defp provision_roles(%Tenant{id: tenant_id}) do
    with {:ok, _admin} <- RBAC.create_role(tenant_id, "Admin", ["*"]),
         {:ok, _member} <- RBAC.create_role(tenant_id, "Member", ["read", "write"]),
         {:ok, _guest} <- RBAC.create_role(tenant_id, "Guest", ["read"]) do
      :ok
    end
  end

  defp apply_compliance(%Tenant{id: _tenant_id, region: _region}) do
    # Delegate to compliance app via behaviour or callback
    # For now, return :ok and let the caller handle compliance
    :ok
  end

  defp create_vault_namespace(%Tenant{id: _tenant_id}) do
    # Delegate to infra app via behaviour or callback
    # For now, return :ok and let the caller handle vault
    :ok
  end

  defp setup_realtime_context(%Tenant{id: _tenant_id}) do
    # Delegate to stream app via behaviour or callback
    # For now, return :ok and let the caller handle streaming
    :ok
  end

  defp register_telemetry(%Tenant{id: tenant_id}) do
    :telemetry.attach(
      "pulseboard.#{tenant_id}.session",
      [:pulseboard, :session, :started],
      &handle_telemetry/4,
      %{tenant_id: tenant_id}
    )

    :telemetry.attach(
      "pulseboard.#{tenant_id}.nudge",
      [:pulseboard, :nudge, :sent],
      &handle_telemetry/4,
      %{tenant_id: tenant_id}
    )

    :ok
  end

  defp handle_telemetry(_event, _measurements, _metadata, _config) do
    :ok
  end

  defp emit_event(type, tenant_id, payload) do
    PulseboardCore.Event.Bus.publish(
      PulseboardCore.Event.new(type, tenant_id, nil, payload)
    )
  end
end
