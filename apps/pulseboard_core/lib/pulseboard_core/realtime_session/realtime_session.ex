defmodule PulseboardCore.RealtimeSession do
  @moduledoc """
  RealtimeSession aggregate root.

  A reusable collaboration primitive that abstracts:
  - Who is involved (participants, roles, guests)
  - What is happening (call, screen share, onboarding, support)
  - Where it's embedded (chat, dashboard, onboarding flow)
  - How it's recorded, stored, and replayed
  """

  @enforce_keys [:id, :tenant_id, :participants, :context, :mode]
  defstruct [
    :id,
    :tenant_id,
    :participants,
    :context,
    :context_id,
    :mode,
    :status,
    :recording_url,
    :transcript,
    :started_at,
    :ended_at,
    :metadata
  ]

  @type mode :: :call | :screenshare | :co_browsing
  @type context :: :task | :pulse | :support_ticket | :onboarding_step | :general
  @type status :: :pending | :active | :recording | :completed | :failed

  @type participant :: %{
    user_id: binary(),
    role: :host | :co_host | :guest,
    joined_at: DateTime.t(),
    left_at: DateTime.t() | nil
  }

  @type t :: %__MODULE__{
    id: binary(),
    tenant_id: binary(),
    participants: [participant()],
    context: context(),
    context_id: binary() | nil,
    mode: mode(),
    status: status(),
    recording_url: binary() | nil,
    transcript: binary() | nil,
    started_at: DateTime.t() | nil,
    ended_at: DateTime.t() | nil,
    metadata: map()
  }

  @valid_modes ~w(call screenshare co_browsing)a
  @valid_contexts ~w(task pulse support_ticket onboarding_step general)a

  @doc """
  Creates a new realtime session.
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) do
    with :ok <- validate_mode(attrs[:mode]),
         :ok <- validate_context(attrs[:context]) do
      session = %__MODULE__{
        id: attrs[:id] || generate_id(),
        tenant_id: Map.fetch!(attrs, :tenant_id),
        participants: Map.get(attrs, :participants, []),
        context: Map.get(attrs, :context, :general),
        context_id: attrs[:context_id],
        mode: Map.get(attrs, :mode, :call),
        status: :pending,
        recording_url: nil,
        transcript: nil,
        started_at: nil,
        ended_at: nil,
        metadata: Map.get(attrs, :metadata, %{})
      }

      {:ok, session}
    end
  end

  @doc """
  Starts the session.
  """
  @spec start(t()) :: t()
  def start(%__MODULE__{} = session) do
    %{session |
      status: :active,
      started_at: DateTime.utc_now()
    }
  end

  @doc """
  Ends the session.
  """
  @spec end_session(t()) :: t()
  def end_session(%__MODULE__{} = session) do
    %{session |
      status: :completed,
      ended_at: DateTime.utc_now()
    }
  end

  @doc """
  Adds a participant to the session.
  """
  @spec add_participant(t(), binary(), :host | :co_host | :guest) :: t()
  def add_participant(%__MODULE__{} = session, user_id, role \\ :guest) do
    participant = %{
      user_id: user_id,
      role: role,
      joined_at: DateTime.utc_now(),
      left_at: nil
    }

    %{session | participants: session.participants ++ [participant]}
  end

  @doc """
  Removes a participant from the session.
  """
  @spec remove_participant(t(), binary()) :: t()
  def remove_participant(%__MODULE__{} = session, user_id) do
    participants =
      Enum.map(session.participants, fn
        %{user_id: ^user_id} = p -> %{p | left_at: DateTime.utc_now()}
        p -> p
      end)

    %{session | participants: participants}
  end

  @doc """
  Sets the recording URL for the session.
  """
  @spec set_recording(t(), binary()) :: t()
  def set_recording(%__MODULE__{} = session, recording_url) do
    %{session |
      recording_url: recording_url,
      status: :recording
    }
  end

  @doc """
  Sets the transcript for the session.
  """
  @spec set_transcript(t(), binary()) :: t()
  def set_transcript(%__MODULE__{} = session, transcript) do
    %{session | transcript: transcript}
  end

  @doc """
  Returns the number of active participants.
  """
  @spec participant_count(t()) :: non_neg_integer()
  def participant_count(%__MODULE__{participants: participants}) do
    Enum.count(participants, fn %{left_at: left_at} -> is_nil(left_at) end)
  end

  defp validate_mode(mode) when mode in @valid_modes, do: :ok
  defp validate_mode(_), do: {:error, :invalid_mode}

  defp validate_context(context) when context in @valid_contexts, do: :ok
  defp validate_context(_), do: {:error, :invalid_context}

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
