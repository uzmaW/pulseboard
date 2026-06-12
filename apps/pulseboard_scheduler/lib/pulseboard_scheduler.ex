defmodule PulseboardScheduler do
  @moduledoc """
  Background job scheduler for PulseBoard.

  Handles tenant onboarding, nudges, retention policies,
  and other background tasks via Oban.
  """

  @doc """
  Schedules a tenant onboarding job.
  """
  @spec schedule_onboarding(map()) :: {:ok, map()} | {:error, term()}
  def schedule_onboarding(attrs) do
    job = %{
      tenant_attrs: attrs,
      scheduled_at: DateTime.utc_now()
    }

    :telemetry.execute(
      [:pulseboard, :scheduler, :onboarding_scheduled],
      %{count: 1},
      %{tenant_name: attrs[:name]}
    )

    {:ok, job}
  end

  @doc """
  Schedules a nudge notification for a user.
  """
  @spec schedule_nudge(binary(), binary(), map()) :: {:ok, map()} | {:error, term()}
  def schedule_nudge(user_id, tenant_id, message) do
    job = %{
      user_id: user_id,
      tenant_id: tenant_id,
      message: message,
      scheduled_at: DateTime.utc_now()
    }

    {:ok, job}
  end

  @doc """
  Schedules a data retention cleanup job.
  """
  @spec schedule_retention_cleanup(binary()) :: {:ok, map()} | {:error, term()}
  def schedule_retention_cleanup(tenant_id) do
    job = %{
      tenant_id: tenant_id,
      scheduled_at: DateTime.utc_now()
    }

    {:ok, job}
  end
end
