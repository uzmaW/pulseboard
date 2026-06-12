defmodule PulseboardWeb.SessionLive do
  @moduledoc """
  Session LiveView for managing realtime collaboration sessions.
  """

  use PulseboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Sessions")
     |> assign(:loading, false)
     |> assign(:sessions, [
       %{
         id: "session-1",
         context: "Support",
         mode: "call",
         status: "active",
         participants: [%{user_id: "user-1", role: "host"}],
         started_at: DateTime.utc_now()
       },
       %{
         id: "session-2",
         context: "Onboarding",
         mode: "screenshare",
         status: "completed",
         participants: [%{user_id: "user-2", role: "host"}],
         started_at: DateTime.add(DateTime.utc_now(), -3600, :second)
       }
     ])}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    session = %{
      id: id,
      tenant_id: "tenant-1",
      participants: [%{user_id: "user-1", role: "host", joined_at: DateTime.utc_now()}],
      context: "Support",
      mode: "call",
      status: "active",
      recording_url: nil,
      transcript: nil,
      started_at: DateTime.utc_now(),
      ended_at: nil
    }

    {:noreply,
     socket
     |> assign(:page_title, "Session #{id}")
     |> assign(:session, session)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Sessions")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @live_action == :index do %>
        <%# Session List %>
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Sessions</h1>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
              Manage your realtime collaboration sessions.
            </p>
          </div>
          <.link navigate="/sessions/new" class="btn btn-primary">
            <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            New Session
          </.link>
        </div>

        <%= if @sessions == [] do %>
          <div class="card">
            <div class="empty-state">
              <svg class="empty-state-icon" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 10.5l4.72-4.72a.75.75 0 011.28.53v11.38a.75.75 0 01-1.28.53l-4.72-4.72M4.5 18.75h9a2.25 2.25 0 002.25-2.25v-9a2.25 2.25 0 00-2.25-2.25h-9A2.25 2.25 0 002.25 7.5v9a2.25 2.25 0 002.25 2.25z" />
              </svg>
              <h3 class="empty-state-title">No sessions yet</h3>
              <p class="empty-state-description">Create your first session to get started.</p>
              <.link navigate="/sessions/new" class="btn btn-primary">
                Create Session
              </.link>
            </div>
          </div>
        <% else %>
          <div class="space-y-4">
            <%= for session <- @sessions do %>
              <div class="session-card">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-4">
                    <div class={"w-3 h-3 rounded-full #{if session.status == "active", do: "bg-emerald-500", else: "bg-gray-400"}"}></div>
                    <div>
                      <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{session.context}</h3>
                      <div class="flex items-center space-x-3 mt-1">
                        <span class={"badge #{if session.status == "active", do: "badge-success", else: "badge-default"}"}>
                          {session.status}
                        </span>
                        <span class="badge badge-info">{session.mode}</span>
                        <span class="text-xs text-gray-500 dark:text-gray-400">
                          {length(session.participants)} participant(s)
                        </span>
                      </div>
                    </div>
                  </div>
                  <.link navigate={"/sessions/#{session.id}"} class="btn btn-secondary btn-sm">
                    View Details
                  </.link>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      <% else %>
        <%# Session Detail %>
        <div class="mb-6">
          <.link navigate="/sessions" class="inline-flex items-center text-sm font-medium text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300">
            <svg class="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
            </svg>
            Back to Sessions
          </.link>
        </div>

        <div class="card">
          <div class="card-header">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-xl font-bold text-gray-900 dark:text-white">Session {@session.id}</h1>
                <div class="flex items-center space-x-3 mt-1">
                  <span class={"badge #{if @session.status == "active", do: "badge-success", else: "badge-default"}"}>
                    {@session.status}
                  </span>
                  <span class="badge badge-info">{@session.mode}</span>
                </div>
              </div>
              <div class="flex space-x-2">
                <%= if @session.status == "active" do %>
                  <button class="btn btn-danger btn-sm">
                    End Session
                  </button>
                <% end %>
              </div>
            </div>
          </div>
          <div class="card-body">
            <dl class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Context</dt>
                <dd class="mt-1 text-sm text-gray-900 dark:text-white">{@session.context}</dd>
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Mode</dt>
                <dd class="mt-1 text-sm text-gray-900 dark:text-white">{@session.mode}</dd>
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Started At</dt>
                <dd class="mt-1 text-sm text-gray-900 dark:text-white">
                  {Calendar.strftime(@session.started_at, "%b %d, %Y at %I:%M %p")}
                </dd>
              </div>
              <div>
                <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Participants</dt>
                <dd class="mt-1 text-sm text-gray-900 dark:text-white">{length(@session.participants)}</dd>
              </div>
            </dl>

            <%# Participants List %>
            <div class="mt-6">
              <h3 class="text-sm font-medium text-gray-900 dark:text-white mb-3">Participants</h3>
              <ul class="space-y-2" role="list">
                <%= for participant <- @session.participants do %>
                  <% _ = participant %>
                  <li class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                    <div class="flex items-center space-x-3">
                      <div class="w-8 h-8 rounded-full bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center">
                        <svg class="w-4 h-4 text-primary-600 dark:text-primary-400" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                        </svg>
                      </div>
                      <div>
                        <p class="text-sm font-medium text-gray-900 dark:text-white">{participant.user_id}</p>
                        <p class="text-xs text-gray-500 dark:text-gray-400">{participant.role}</p>
                      </div>
                    </div>
                    <span class="text-xs text-gray-500 dark:text-gray-400">
                      Joined {Calendar.strftime(participant.joined_at, "%I:%M %p")}
                    </span>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
