defmodule PulseboardImpersonation do
  @moduledoc """
  Impersonation context for PulseBoard.

  Provides secure, auditable impersonation for support, QA,
  and training purposes.
  """

  alias PulseboardCore.ImpersonationSession

  @doc """
  Starts an impersonation session.
  """
  @spec start(map()) :: {:ok, ImpersonationSession.t()} | {:error, term()}
  def start(attrs) do
    case ImpersonationSession.new(attrs) do
      {:ok, session} ->
        :telemetry.execute(
          [:pulseboard, :impersonation, :started],
          %{count: 1},
          %{admin_id: session.admin_id, target_user_id: session.target_user_id}
        )

        emit_event(:impersonation_started, session.tenant_id, session.admin_id, %{
          target_user_id: session.target_user_id,
          reason: session.reason,
          scope: session.scope
        })

        {:ok, session}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Ends an impersonation session.
  """
  @spec end_session(ImpersonationSession.t()) :: ImpersonationSession.t()
  def end_session(%ImpersonationSession{} = session) do
    session = ImpersonationSession.end_session(session)

    :telemetry.execute(
      [:pulseboard, :impersonation, :ended],
      %{count: 1},
      %{admin_id: session.admin_id}
    )

    emit_event(:impersonation_ended, session.tenant_id, session.admin_id, %{
      target_user_id: session.target_user_id,
      duration: DateTime.diff(session.ended_at, session.started_at, :second)
    })

    session
  end

  @doc """
  Checks if a user is currently impersonating someone.
  """
  @spec impersonating?(ImpersonationSession.t()) :: boolean()
  def impersonating?(%ImpersonationSession{} = session) do
    ImpersonationSession.active?(session)
  end

  @doc """
  Checks if an action is allowed during impersonation.
  """
  @spec action_allowed?(ImpersonationSession.t(), binary()) :: boolean()
  def action_allowed?(%ImpersonationSession{} = session, action) do
    ImpersonationSession.action_allowed?(session, action)
  end

  defp emit_event(type, tenant_id, user_id, payload) do
    PulseboardCore.Event.Bus.publish(
      PulseboardCore.Event.new(type, tenant_id, user_id, payload)
    )
  end
end
