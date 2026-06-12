defmodule PulseboardCore.Compliance.CompliancePolicy do
  @moduledoc """
  CompliancePolicy aggregate root.

  Represents regional data governance policies including
  retention, consent, and audit requirements.
  """

  @enforce_keys [:id, :tenant_id, :region]
  defstruct [
    :id,
    :tenant_id,
    :region,
    :retention_days,
    :consent_required,
    :audit_enabled,
    :data_classification,
    :created_at,
    :updated_at
  ]

  @type data_classification :: :public | :internal | :confidential | :restricted

  @type t :: %__MODULE__{
    id: binary(),
    tenant_id: binary(),
    region: binary(),
    retention_days: non_neg_integer(),
    consent_required: boolean(),
    audit_enabled: boolean(),
    data_classification: data_classification(),
    created_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  @doc """
  Creates a new compliance policy.
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) do
    policy = %__MODULE__{
      id: attrs[:id] || generate_id(),
      tenant_id: Map.fetch!(attrs, :tenant_id),
      region: Map.fetch!(attrs, :region),
      retention_days: Map.get(attrs, :retention_days, 365),
      consent_required: Map.get(attrs, :consent_required, false),
      audit_enabled: Map.get(attrs, :audit_enabled, true),
      data_classification: Map.get(attrs, :data_classification, :confidential),
      created_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    {:ok, policy}
  end

  @doc """
  Returns true if data retention has exceeded the policy period.
  """
  @spec retention_exceeded?(t(), DateTime.t()) :: boolean()
  def retention_exceeded?(%__MODULE__{retention_days: days}, data_timestamp) do
    cutoff = DateTime.add(DateTime.utc_now(), -days, :day)
    DateTime.compare(data_timestamp, cutoff) == :lt
  end

  @doc """
  Returns true if consent is required for the given action.
  */
  @spec consent_required?(t()) :: boolean()
  def consent_required?(%__MODULE__{consent_required: required}), do: required

  @doc """
  Returns region-specific default settings.
  """
  @spec region_defaults(binary()) :: map()
  def region_defaults("EU"), do: %{retention_days: 90, consent_required: true, audit_enabled: true}
  def region_defaults("US"), do: %{retention_days: 365, consent_required: false, audit_enabled: true}
  def region_defaults("APAC"), do: %{retention_days: 180, consent_required: true, audit_enabled: true}
  def region_defaults(_), do: %{retention_days: 365, consent_required: false, audit_enabled: true}

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
