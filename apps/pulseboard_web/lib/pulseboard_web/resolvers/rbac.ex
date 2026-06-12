defmodule PulseboardWeb.Resolvers.RBAC do
  @moduledoc """
  GraphQL resolvers for RBAC mutations.
  """

  alias PulseboardCore.RBAC

  def assign_role(_parent, args, _resolution) do
    case RBAC.assign_role(args[:user_id], args[:role_id], args[:tenant_id]) do
      {:ok, assignment} ->
        {:ok,
         %{
           id: assignment.id,
           user_id: assignment.user_id,
           role_id: assignment.role_id,
           tenant_id: assignment.tenant_id,
           assigned_at: assignment.assigned_at
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
