defmodule PulseboardCore.RBAC.Permission do
  @moduledoc """
  RBAC Permission struct.

  Represents a specific permission (resource + action combination).
  """

  @enforce_keys [:resource, :action]
  defstruct [
    :resource,
    :action,
    :description
  ]

  @type t :: %__MODULE__{
    resource: binary(),
    action: binary(),
    description: binary() | nil
  }

  @doc """
  Creates a new permission.
  """
  @spec new(binary(), binary(), binary() | nil) :: t()
  def new(resource, action, description \\ nil) do
    %__MODULE__{
      resource: resource,
      action: action,
      description: description
    }
  end

  @doc """
  Converts a permission to a string representation.
  """
  @spec to_string(t()) :: binary()
  def to_string(%__MODULE__{resource: resource, action: action}) do
    "#{resource}:#{action}"
  end

  @doc """
  Parses a permission string into a Permission struct.
  """
  @spec from_string(binary()) :: {:ok, t()} | {:error, :invalid_format}
  def from_string(str) when is_binary(str) do
    case String.split(str, ":", parts: 2) do
      [resource, action] ->
        {:ok, new(resource, action)}

      _ ->
        {:error, :invalid_format}
    end
  end
end
