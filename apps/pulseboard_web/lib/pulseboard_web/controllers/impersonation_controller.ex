defmodule PulseboardWeb.ImpersonationController do
  use PulseboardWeb, :controller

  @doc """
  Starts an impersonation session.
  """
  def create(conn, %{"target_user_id" => target_user_id}) do
    user = conn.assigns[:current_user]
    tenant = conn.assigns[:tenant]

    case PulseboardImpersonation.start(%{
           tenant_id: tenant.id,
           admin_id: user.id,
           target_user_id: target_user_id,
           reason: "Manual impersonation",
           scope: :support
         }) do
      {:ok, session} ->
        conn
        |> put_session(:impersonation_session, session)
        |> put_flash(:info, "Impersonation started")
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Failed to start impersonation: #{reason}")
        |> redirect(to: "/impersonate")
    end
  end

  @doc """
  Ends an impersonation session.
  """
  def delete(conn, _params) do
    conn
    |> delete_session(:impersonation_session)
    |> put_flash(:info, "Impersonation ended")
    |> redirect(to: "/")
  end
end
