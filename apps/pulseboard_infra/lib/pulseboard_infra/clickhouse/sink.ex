defmodule PulseboardInfra.ClickHouse.Sink do
  @moduledoc """
  ClickHouse sink for observability data.

  Receives telemetry events and writes them to ClickHouse
  for storage and analysis.
  """

  @doc """
  Pushes an event to ClickHouse.
  """
  @spec push_event(map()) :: :ok | {:error, term()}
  def push_event(event) do
    config = Application.get_env(:pulseboard_infra, :clickhouse, %{})
    url = Keyword.get(config, :url, "http://localhost:8123")

    query = """
    INSERT INTO pulseboard_events (id, type, tenant_id, user_id, payload, timestamp)
    VALUES (
      '#{event.id}',
      '#{event.type}',
      '#{event.tenant_id}',
      '#{event.user_id || ""}',
      '#{Jason.encode!(event.payload)}',
      '#{DateTime.to_iso8601(event.timestamp)}'
    )
    """

    case HTTPoison.post("#{url}/", query, [{"Content-Type", "text/plain"}]) do
      {:ok, %{status_code: 200}} -> :ok
      {:ok, %{status_code: status, body: body}} -> {:error, {:http_error, status, body}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Pushes a batch of events to ClickHouse.
  """
  @spec push_events([map()]) :: :ok | {:error, term()}
  def push_events(events) when is_list(events) do
    config = Application.get_env(:pulseboard_infra, :clickhouse, %{})
    url = Keyword.get(config, :url, "http://localhost:8123")

    values =
      events
      |> Enum.map(fn event ->
        "('#{event.id}', '#{event.type}', '#{event.tenant_id}', '#{event.user_id || ""}', '#{Jason.encode!(event.payload)}', '#{DateTime.to_iso8601(event.timestamp)}')"
      end)
      |> Enum.join(",\n")

    query = """
    INSERT INTO pulseboard_events (id, type, tenant_id, user_id, payload, timestamp)
    VALUES #{values}
    """

    case HTTPoison.post("#{url}/", query, [{"Content-Type", "text/plain"}]) do
      {:ok, %{status_code: 200}} -> :ok
      {:ok, %{status_code: status, body: body}} -> {:error, {:http_error, status, body}}
      {:error, reason} -> {:error, reason}
    end
  end
end
