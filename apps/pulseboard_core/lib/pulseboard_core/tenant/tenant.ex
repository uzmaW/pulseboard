defmodule PulseboardCore.Tenant do
  @moduledoc """
  Tenant aggregate root.

  Represents a multi-tenant organization with region-specific
  compliance policies, RBAC roles, and isolated secrets.
  """

  @enforce_keys [:id, :name, :region, :domain, :admin_user_id]
  defstruct [
    :id,
    :name,
    :region,
    :domain,
    :admin_user_id,
    :created_at,
    :updated_at,
    :settings,
    :status
  ]

  @type region :: :us | :eu | :apac | :global
  @type status :: :active | :suspended | :pending

  @type t :: %__MODULE__{
    id: binary(),
    name: binary(),
    region: region(),
    domain: binary(),
    admin_user_id: binary(),
    created_at: DateTime.t(),
    updated_at: DateTime.t(),
    settings: map(),
    status: status()
  }

  @valid_regions ~w(us eu apac global)a

  @doc """
  Creates a new tenant with the given attributes.
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) do
    with :ok <- validate_region(attrs[:region]) do
      tenant = %__MODULE__{
        id: attrs[:id] || generate_id(),
        name: Map.fetch!(attrs, :name),
        region: attrs[:region],
        domain: Map.fetch!(attrs, :domain),
        admin_user_id: Map.fetch!(attrs, :admin_user_id),
        created_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now(),
        settings: Map.get(attrs, :settings, %{}),
        status: :pending
      }

      {:ok, tenant}
    end
  end

  @doc """
  Activates a tenant after onboarding is complete.
  """
  @spec activate(t()) :: t()
  def activate(%__MODULE__{} = tenant) do
    %{tenant | status: :active, updated_at: DateTime.utc_now()}
  end

  @doc """
  Suspends a tenant.
  """
  @spec suspend(t()) :: t()
  def suspend(%__MODULE__{} = tenant) do
    %{tenant | status: :suspended, updated_at: DateTime.utc_now()}
  end

  @doc """
  Returns true if the tenant is active.
  """
  @spec active?(t()) :: boolean()
  def active?(%__MODULE__{status: :active}), do: true
  def active?(%__MODULE__{}), do: false

  @doc """
  Returns all valid regions.
  """
  @spec valid_regions() :: [region()]
  def valid_regions, do: @valid_regions

  defp validate_region(region) when region in @valid_regions, do: :ok
  defp validate_region(_region), do: {:error, :invalid_region}

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
