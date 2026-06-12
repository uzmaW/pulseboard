defmodule PulseboardWeb.Plugs.FetchTenant do
  @moduledoc """
  Plug to fetch the current tenant from the request.

  Extracts tenant information from the host/subdomain
  and assigns it to the connection.
  """

  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    host = conn.host || "localhost"

    tenant = extract_tenant(host)

    assign(conn, :tenant, tenant)
  end

  defp extract_tenant(host) do
    case String.split(host, ".") do
      [subdomain, _domain, _tld] ->
        %{
          id: subdomain,
          name: String.capitalize(subdomain),
          domain: host
        }

      _ ->
        %{
          id: "default",
          name: "Default",
          domain: host
        }
    end
  end
end
