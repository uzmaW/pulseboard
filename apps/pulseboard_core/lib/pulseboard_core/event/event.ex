defmodule PulseboardCore.Event do
  @moduledoc """
  Base event struct for domain events.

  All domain events should struct this struct and be emitted
  through the event bus for observability, audit, and automation.
  """

  @enforce_keys [:id, :type, :timestamp, :tenant_id]
  defstruct [
    :id,
    :type,
    :timestamp,
    :tenant_id,
    :user_id,
    :payload,
    :metadata
  ]

  @type t :: %__MODULE__{
    id: binary(),
    type: atom(),
    timestamp: DateTime.t(),
    tenant_id: binary(),
    user_id: binary() | nil,
    payload: map() | nil,
    metadata: map()
  }

  @doc """
  Creates a new event with the given type, tenant_id, and optional payload.
  """
  @spec new(atom(), binary(), binary() | nil, map()) :: t()
  def new(type, tenant_id, user_id \\ nil, payload \\ %{}) do
    %__MODULE__{
      id: generate_id(),
      type: type,
      timestamp: DateTime.utc_now(),
      tenant_id: tenant_id,
      user_id: user_id,
      payload: payload,
      metadata: %{}
    }
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
