defmodule PulseboardCore.ImpersonationSession do
  @moduledoc """
  ImpersonationSession aggregate root.

  Secure, auditable impersonation for support, QA, and training.
  Every impersonation is logged with admin_id, target_user_id,
  reason, and timestamp for compliance and audit purposes.
  """

  @enforce_keys [:id, :tenant_id, :admin_id, :target_user_id, :reason]
  defstruct [
    :id,
    :tenant_id,
    :admin_id,
    :target_user_id,
    :reason,
    :started_at,
    :ended_at,
    :status,
    :scope,
    :audit_trail
  ]

  @type status :: :active | :completed | :revoked
  @type scope :: :support | :qa | :training | :debugging

  @type audit_entry :: %{
    action: binary(),
    timestamp: DateTime.t(),
    target_resource: binary() | nil
  }

  @type t :: %__MODULE__{
    id: binary(),
    tenant_id: binary(),
    admin_id: binary(),
    target_user_id: binary(),
    reason: binary(),
    started_at: DateTime.t(),
    ended_at: DateTime.t() | nil,
    status: status(),
    scope: scope(),
    audit_trail: [audit_entry()]
  }

  @restricted_actions ~w(
    change_password
    update_billing
    delete_account
    manage_api_keys
    change_email
  )

  @doc """
  Creates a new impersonation session.
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) do
    session = %__MODULE__{
      id: attrs[:id] || generate_id(),
      tenant_id: Map.fetch!(attrs, :tenant_id),
      admin_id: Map.fetch!(attrs, :admin_id),
      target_user_id: Map.fetch!(attrs, :target_user_id),
      reason: Map.fetch!(attrs, :reason),
      started_at: DateTime.utc_now(),
      ended_at: nil,
      status: :active,
      scope: Map.get(attrs, :scope, :support),
      audit_trail: []
    }

    {:ok, session}
  end

  @doc """
  Ends the impersonation session.
  """
  @spec end_session(t()) :: t()
  def end_session(%__MODULE__{} = session) do
    %{session |
      status: :completed,
      ended_at: DateTime.utc_now()
    }
  end

  @doc """
  Revokes the impersonation session (e.g., security concern).
  """
  @spec revoke(t()) :: t()
  def revoke(%__MODULE__{} = session) do
    %{session |
      status: :revoked,
      ended_at: DateTime.utc_now()
    }
  end

  @doc """
  Logs an action in the audit trail.
  """
  @spec log_action(t(), binary(), binary() | nil) :: t()
  def log_action(%__MODULE__{} = session, action, target_resource \\ nil) do
    entry = %{
      action: action,
      timestamp: DateTime.utc_now(),
      target_resource: target_resource
    }

    %{session | audit_trail: session.audit_trail ++ [entry]}
  end

  @doc """
  Returns true if the action is allowed during impersonation.
  """
  @spec action_allowed?(t(), binary()) :: boolean()
  def action_allowed?(%__MODULE__{}, action) do
    action not in @restricted_actions
  end

  @doc """
  Returns true if the impersonation session is active.
  """
  @spec active?(t()) :: boolean()
  def active?(%__MODULE__{status: :active}), do: true
  def active?(%__MODULE__{}), do: false

  @doc """
  Returns the list of restricted actions.
  """
  @spec restricted_actions() :: [binary()]
  def restricted_actions, do: @restricted_actions

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
