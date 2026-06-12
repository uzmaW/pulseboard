defmodule PulseboardCore.Event.Bus do
  @moduledoc """
  In-process event bus for domain events.

  Uses Erlang's `:pg` (process groups) for lightweight pub/sub
  without external dependencies. For production, replace with
  a distributed event bus (e.g., Phoenix.PubSub, Kafka, NATS).
  """

  @doc """
  Publishes an event to all subscribers of the event type.
  """
  @spec publish(PulseboardCore.Event.t()) :: :ok
  def publish(%PulseboardCore.Event{} = event) do
    :telemetry.execute(
      [:pulseboard, :event, :published],
      %{count: 1},
      %{event_type: event.type, tenant_id: event.tenant_id}
    )

    notify_subscribers(event)
    :ok
  end

  @doc """
  Subscribes the calling process to events of the given type.
  """
  @spec subscribe(atom()) :: :ok | {:error, any()}
  def subscribe(event_type) do
    group = group_name(event_type)

    case :pg.start_link(__MODULE__) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end

    :pg.join(__MODULE__, group, self())
  end

  @doc """
  Unsubscribes the calling process from events of the given type.
  """
  @spec unsubscribe(atom()) :: :ok
  def unsubscribe(event_type) do
    group = group_name(event_type)
    :pg.leave(__MODULE__, group, self())
  end

  defp notify_subscribers(%PulseboardCore.Event{type: type} = event) do
    group = group_name(type)

    try do
      :pg.get_members(__MODULE__, group)
      |> Enum.each(fn pid ->
        send(pid, {:event, event})
      end)
    rescue
      ArgumentError -> :ok
    end
  end

  defp group_name(event_type), do: {__MODULE__, event_type}
end
