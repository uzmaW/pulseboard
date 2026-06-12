defmodule PulseboardCore.RBAC do
  @moduledoc """
  RBAC context module.

  Provides functions for managing roles, permissions, and
  assignments within a tenant.
  """

  alias PulseboardCore.RBAC.Role
  alias PulseboardCore.RBAC.Assignment

  @doc """
  Creates a new role for a tenant.
  """
  @spec create_role(binary(), binary(), [binary()]) :: {:ok, Role.t()} | {:error, term()}
  def create_role(tenant_id, name, permissions \\ []) do
    Role.new(%{
      tenant_id: tenant_id,
      name: name,
      permissions: permissions
    })
  end

  @doc """
  Assigns a role to a user within a tenant.
  """
  @spec assign_role(binary(), binary(), binary()) :: {:ok, Assignment.t()} | {:error, term()}
  def assign_role(user_id, role_id, tenant_id) do
    Assignment.new(%{
      user_id: user_id,
      role_id: role_id,
      tenant_id: tenant_id
    })
  end

  @doc """
  Returns true if the user has at least one of the required roles.
  """
  @spec allowed?(binary(), binary(), [binary()], [Role.t()]) :: boolean()
  def allowed?(_user_id, tenant_id, required_roles, user_roles) do
    user_roles
    |> Enum.filter(fn role -> role.tenant_id == tenant_id end)
    |> Enum.any?(fn role ->
      role.name in required_roles
    end)
  end

  @doc """
  Returns true if the user has the given permission.
  """
  @spec has_permission?(binary(), [Role.t()]) :: boolean()
  def has_permission?(permission, user_roles) do
    Enum.any?(user_roles, fn role ->
      Role.has_permission?(role, permission)
    end)
  end

  @doc """
  Returns the default roles for a tenant.
  """
  @spec default_roles() :: [map()]
  def default_roles do
    [
      %{name: "Admin", permissions: ["*"]},
      %{name: "Member", permissions: ["read", "write", "sessions:create", "sessions:join"]},
      %{name: "Guest", permissions: ["read", "sessions:join"]}
    ]
  end
end
