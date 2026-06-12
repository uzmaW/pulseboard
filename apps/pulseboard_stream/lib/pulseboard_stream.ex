defmodule PulseboardStream do
  @moduledoc """
  Real-time collaboration primitives for PulseBoard.

  Provides WebRTC, recording, and transcript capabilities
  via LiveKit integration.
  """

  @doc """
  Creates a new LiveKit room for real-time collaboration.
  """
  @spec create_room(binary()) :: {:ok, map()} | {:error, term()}
  def create_room(room_id) do
    case PulseboardStream.LiveKit.create_room(room_id) do
      {:ok, room} ->
        :telemetry.execute(
          [:pulseboard, :stream, :room_created],
          %{count: 1},
          %{room_id: room_id}
        )

        {:ok, room}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a LiveKit room.
  """
  @spec delete_room(binary()) :: :ok | {:error, term()}
  def delete_room(room_id) do
    PulseboardStream.LiveKit.delete_room(room_id)
  end

  @doc """
  Generates an access token for a participant.
  """
  @spec generate_token(binary(), binary(), binary()) :: {:ok, binary()} | {:error, term()}
  def generate_token(room_id, participant_id, identity) do
    PulseboardStream.LiveKit.generate_token(room_id, participant_id, identity)
  end
end
