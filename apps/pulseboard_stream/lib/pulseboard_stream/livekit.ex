defmodule PulseboardStream.LiveKit do
  @moduledoc """
  LiveKit client for WebRTC collaboration.

  Provides room management, participant handling, and
  recording capabilities via LiveKit's HTTP API.
  """

  @doc """
  Creates a new LiveKit room.
  """
  @spec create_room(binary()) :: {:ok, map()} | {:error, term()}
  def create_room(room_id) do
    config = Application.get_env(:pulseboard_stream, :livekit, [])
    api_key = Keyword.get(config, :api_key, "dev-api-key")
    _api_secret = Keyword.get(config, :api_secret, "dev-api-secret")
    url = Keyword.get(config, :url, "http://localhost:7880")

    body = %{name: room_id, empty_timeout: 300, max_participants: 10}

    case HTTPoison.post(
           "#{url}/rooms",
           Jason.encode!(body),
           [{"Content-Type", "application/json"}, {"Authorization", "Bearer #{api_key}"}]
         ) do
      {:ok, %{status_code: 201, body: response}} ->
        {:ok, Jason.decode!(response)}

      {:ok, %{status_code: 409, body: _}} ->
        {:ok, %{name: room_id}}

      {:ok, %{status_code: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a LiveKit room.
  """
  @spec delete_room(binary()) :: :ok | {:error, term()}
  def delete_room(room_id) do
    config = Application.get_env(:pulseboard_stream, :livekit, [])
    api_key = Keyword.get(config, :api_key, "dev-api-key")
    url = Keyword.get(config, :url, "http://localhost:7880")

    case HTTPoison.delete(
           "#{url}/rooms/#{room_id}",
           [{"Authorization", "Bearer #{api_key}"}]
         ) do
      {:ok, %{status_code: 200}} -> :ok
      {:ok, %{status_code: status, body: body}} -> {:error, {:http_error, status, body}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generates an access token for a participant.
  """
  @spec generate_token(binary(), binary(), binary()) :: {:ok, binary()} | {:error, term()}
  def generate_token(room_id, participant_id, identity) do
    config = Application.get_env(:pulseboard_stream, :livekit, [])
    api_secret = Keyword.get(config, :api_secret, "dev-api-secret")

    now = System.system_time(:second)

    claims = %{
      "iss" => "pulseboard",
      "sub" => participant_id,
      "identity" => identity,
      "room" => room_id,
      "roomJoin" => true,
      "iat" => now,
      "nbf" => now,
      "exp" => now + 86400
    }

    token = encode_jwt(claims, api_secret)
    {:ok, token}
  end

  defp encode_jwt(claims, secret) do
    header = %{"alg" => "HS256", "typ" => "JWT"} |> Jason.encode!() |> Base.url_encode64(padding: false)
    payload = claims |> Jason.encode!() |> Base.url_encode64(padding: false)
    signature = :crypto.mac(:hmac, :sha256, secret, "#{header}.#{payload}") |> Base.url_encode64(padding: false)

    "#{header}.#{payload}.#{signature}"
  end
end
