defmodule PulseboardWeb.Resolvers.Impersonation do
  @moduledoc """
  GraphQL resolvers for Impersonation mutations.
  """

  alias PulseboardCore.ImpersonationSession

  def start(_parent, args, %{context: %{current_user: user, tenant: tenant}}) do
    attrs = %{
      tenant_id: tenant.id,
      admin_id: user.id,
      target_user_id: args[:target_user_id],
      reason: args[:reason],
      scope: String.to_existing_atom(args[:scope] || "support")
    }

    case ImpersonationSession.new(attrs) do
      {:ok, session} ->
        {:ok,
         %{
           id: session.id,
           tenant_id: session.tenant_id,
           admin_id: session.admin_id,
           target_user_id: session.target_user_id,
           reason: session.reason,
           scope: Atom.to_string(session.scope),
           started_at: session.started_at,
           ended_at: nil,
           status: Atom.to_string(session.status)
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def start(_parent, _args, _resolution) do
    {:error, "Authentication required"}
  end

  def end_session(_parent, %{session_id: id}, _resolution) do
    # In production, fetch and end the session
    {:ok,
     %{
       id: id,
       tenant_id: "tenant-1",
       admin_id: "admin-1",
       target_user_id: "user-1",
       reason: "Support request",
       scope: "support",
       started_at: DateTime.utc_now(),
       ended_at: DateTime.utc_now(),
       status: "completed"
     }}
  end
end
