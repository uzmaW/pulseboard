defmodule PulseboardInfra.Vault do
  @moduledoc """
  Vault client for secrets management.

  Provides a simple interface for interacting with HashiCorp Vault
  for tenant-scoped secrets management.
  """

  @doc """
  Creates a new namespace in Vault for a tenant.
  """
  @spec create_namespace(binary()) :: :ok | {:error, term()}
  def create_namespace(tenant_id) do
    path = "tenant-#{tenant_id}"

    case vault_request(:post, "sys/mounts/#{path}", %{type: "kv", options: %{"version" => "2"}}) do
      {:ok, _} -> :ok
      {:error, :already_exists} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Writes a secret to Vault for a tenant.
  """
  @spec write_secret(binary(), binary(), map()) :: :ok | {:error, term()}
  def write_secret(tenant_id, key, value) do
    path = "tenant-#{tenant_id}/data/#{key}"

    case vault_request(:post, path, %{data: value}) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Reads a secret from Vault for a tenant.
  """
  @spec read_secret(binary(), binary()) :: {:ok, map()} | {:error, term()}
  def read_secret(tenant_id, key) do
    path = "tenant-#{tenant_id}/data/#{key}"

    case vault_request(:get, path) do
      {:ok, %{data: %{data: data}}} -> {:ok, data}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deletes a secret from Vault for a tenant.
  """
  @spec delete_secret(binary(), binary()) :: :ok | {:error, term()}
  def delete_secret(tenant_id, key) do
    path = "tenant-#{tenant_id}/data/#{key}"

    case vault_request(:delete, path) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Lists all secrets for a tenant.
  """
  @spec list_secrets(binary()) :: {:ok, [binary()]} | {:error, term()}
  def list_secrets(tenant_id) do
    path = "tenant-#{tenant_id}/data/"

    case vault_request(:list, path) do
      {:ok, %{data: %{keys: keys}}} -> {:ok, keys}
      {:error, reason} -> {:error, reason}
    end
  end

  defp vault_request(method, path, body \\ nil) do
    config = Application.get_env(:pulseboard_infra, :vault, %{})
    addr = Keyword.get(config, :addr, "http://localhost:8200")
    token = Keyword.get(config, :token, "")

    url = "#{addr}/v1/#{path}"

    headers = [
      {"X-Vault-Token", token},
      {"Content-Type", "application/json"}
    ]

    request =
      case method do
        :get -> {url, headers}
        :post -> {url, headers, "application/json", Jason.encode!(body || %{})}
        :delete -> {url, headers}
        :list -> {"#{url}?list=true", headers}
      end

    case :hackney.request(method, request) do
      {:ok, 200, _headers, body} ->
        Jason.decode(body)

      {:ok, 404, _headers, _body} ->
        {:error, :not_found}

      {:ok, 409, _headers, _body} ->
        {:error, :already_exists}

      {:ok, status, _headers, body} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
