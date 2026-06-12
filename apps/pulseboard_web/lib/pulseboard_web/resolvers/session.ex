defmodule PulseboardWeb.Resolvers.Session do
  @moduledoc """
  GraphQL resolvers for Session queries and mutations.
  """

  alias PulseboardCore.RealtimeSession

  def get(_parent, %{id: id}, _resolution) do
    # In production, fetch from database
    {:ok,
     %{
       id: id,
       tenant_id: "tenant-1",
       participants: [],
       context: "general",
       context_id: nil,
       mode: "call",
       status: "pending",
       recording_url: nil,
       transcript: nil,
       started_at: nil,
       ended_at: nil
     }}
  end

  def list(_parent, _args, _resolution) do
    # In production, fetch from database
    {:ok, []}
  end

  def create(_parent, args, %{context: %{current_user: user, tenant: tenant}}) do
    attrs = %{
      tenant_id: tenant.id,
      context: String.to_existing_atom(args[:context]),
      context_id: args[:context_id],
      mode: String.to_existing_atom(args[:mode] || "call"),
      participants: [%{user_id: user.id, role: :host}]
    }

    case RealtimeSession.new(attrs) do
      {:ok, session} ->
        {:ok, RealtimeSession.start(session)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def create(_parent, _args, _resolution) do
    {:error, "Authentication required"}
  end
end
