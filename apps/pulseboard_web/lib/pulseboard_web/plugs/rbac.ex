defmodule PulseboardWeb.Plugs.RBAC do
  @moduledoc """
  Plug for role-based access control.

  Checks if the current user has the required roles
  before allowing access to the route.
  """

  @behaviour Plug

  import Plug.Conn

  alias PulseboardCore.RBAC

  def init(opts), do: opts

  def call(conn, opts) do
    required_roles = Keyword.get(opts, :roles, [])
    user = conn.assigns[:current_user]
    tenant = conn.assigns[:tenant]

    if user && tenant && RBAC.allowed?(user.id, tenant.id, required_roles, user.roles || []) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> Phoenix.Controller.json(%{error: "Forbidden"})
      |> halt()
    end
  end
end
