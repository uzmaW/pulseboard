defmodule PulseboardWeb.RBACHelpers do
  @moduledoc """
  Helper functions for RBAC enforcement in LiveViews.
  """

  @doc """
  Returns true if the user has the given role.
  """
  @spec has_role?(map(), binary()) :: boolean()
  def has_role?(assigns, role_name) do
    user = assigns[:current_user]
    roles = user[:roles] || []

    Enum.any?(roles, fn role ->
      role[:name] == role_name
    end)
  end

  @doc """
  Returns true if the user has any of the given roles.
  """
  @spec has_any_role?(map(), [binary()]) :: boolean()
  def has_any_role?(assigns, role_names) do
    user = assigns[:current_user]
    roles = user[:roles] || []

    Enum.any?(roles, fn role ->
      role[:name] in role_names
    end)
  end

  @doc """
  Returns true if the user has the given permission.
  """
  @spec has_permission?(map(), binary()) :: boolean()
  def has_permission?(assigns, permission) do
    user = assigns[:current_user]
    roles = user[:roles] || []

    Enum.any?(roles, fn role ->
      permissions = role[:permissions] || []
      "*" in permissions || permission in permissions
    end)
  end
end
