defmodule PulseboardWeb.Plugs.FetchCurrentUser do
  @moduledoc """
  Plug to fetch the current user from the session.

  In production, this would use Guardian or Pow to
  decode and verify the JWT token.
  """

  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    # Stub implementation - in production, decode JWT from session/token
    user = %{
      id: "user-1",
      name: "Demo User",
      email: "demo@pulseboard.dev",
      roles: []
    }

    assign(conn, :current_user, user)
  end
end
