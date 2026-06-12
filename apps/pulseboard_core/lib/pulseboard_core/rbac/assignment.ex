defmodule PulseboardCore.RBAC.Assignment do
  @moduledoc """
  RBAC Assignment struct.

  Represents the assignment of a role to a user within a tenant.
  """

  @enforce_keys [:id, :user_id, :role_id, :tenant_id]
  defstruct [
    :id,
    :user_id,
    :role_id,
    :tenant_id,
    :assigned_at,
    :assigned_by
  ]

  @type t :: %__MODULE__{
    id: binary(),
    user_id: binary(),
    role_id: binary(),
    tenant_id: binary(),
    assigned_at: DateTime.t(),
    assigned_by: binary() | nil
  }

  @doc """
  Creates a new assignment.
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) do
    assignment = %__MODULE__{
      id: attrs[:id] || generate_id(),
      user_id: Map.fetch!(attrs, :user_id),
      role_id: Map.fetch!(attrs, :role_id),
      tenant_id: Map.fetch!(attrs, :tenant_id),
      assigned_at: DateTime.utc_now(),
      assigned_by: attrs[:assigned_by]
    }

    {:ok, assignment}
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
