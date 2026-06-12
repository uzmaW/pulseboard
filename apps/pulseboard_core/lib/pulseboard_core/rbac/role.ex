defmodule PulseboardCore.RBAC.Role do
  @moduledoc """
  RBAC Role struct.

  Represents a role within a tenant with associated permissions.
  """

  @enforce_keys [:id, :tenant_id, :name, :permissions]
  defstruct [
    :id,
    :tenant_id,
    :name,
    :permissions,
    :created_at
  ]

  @type t :: %__MODULE__{
    id: binary(),
    tenant_id: binary(),
    name: binary(),
    permissions: [binary()],
    created_at: DateTime.t()
  }

  @doc """
  Creates a new role.
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) do
    role = %__MODULE__{
      id: attrs[:id] || generate_id(),
      tenant_id: Map.fetch!(attrs, :tenant_id),
      name: Map.fetch!(attrs, :name),
      permissions: Map.get(attrs, :permissions, []),
      created_at: DateTime.utc_now()
    }

    {:ok, role}
  end

  @doc """
  Adds a permission to the role.
  """
  @spec add_permission(t(), binary()) :: t()
  def add_permission(%__MODULE__{} = role, permission) do
    %{role | permissions: role.permissions ++ [permission]}
  end

  @doc """
  Removes a permission from the role.
  """
  @spec remove_permission(t(), binary()) :: t()
  def remove_permission(%__MODULE__{} = role, permission) do
    %{role | permissions: List.delete(role.permissions, permission)}
  end

  @doc """
  Returns true if the role has the given permission.
  """
  @spec has_permission?(t(), binary()) :: boolean()
  def has_permission?(%__MODULE__{permissions: ["*"]}, _permission), do: true
  def has_permission?(%__MODULE__{permissions: permissions}, permission) do
    permission in permissions
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
