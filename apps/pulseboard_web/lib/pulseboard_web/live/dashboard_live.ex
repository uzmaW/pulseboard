defmodule PulseboardWeb.DashboardLive do
  @moduledoc """
  Dashboard LiveView for the PulseBoard main page.
  """

  use PulseboardWeb, :live_view

  import PulseboardWeb.RBACHelpers

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:loading, false)
     |> assign(:tenant, %{
       id: "default",
       name: "PulseBoard"
     })
     |> assign(:current_user, %{
       id: "user-1",
       name: "Demo User",
       email: "demo@pulseboard.dev",
       roles: [%{name: "Admin", permissions: ["*"]}]
     })
     |> assign(:stats, %{
       active_sessions: 12,
       total_users: 156,
       impersonation_sessions: 3,
       tenants: 5
     })
     |> assign(:recent_sessions, [
       %{id: "s1", context: "Support", status: "active", created_at: DateTime.utc_now()},
       %{id: "s2", context: "Onboarding", status: "completed", created_at: DateTime.add(DateTime.utc_now(), -3600, :second)},
       %{id: "s3", context: "Training", status: "active", created_at: DateTime.add(DateTime.utc_now(), -7200, :second)}
     ])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Dashboard</h1>
        <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
          Welcome back, {@current_user.name}. Here's what's happening across your tenants.
        </p>
      </div>

      <%# Stats Grid %>
      <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
        <div class="stat-card">
          <div class="flex items-center">
            <div class="stat-card-icon bg-blue-100 dark:bg-blue-900/30">
              <svg class="w-6 h-6 text-blue-600 dark:text-blue-400" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 10.5l4.72-4.72a.75.75 0 011.28.53v11.38a.75.75 0 01-1.28.53l-4.72-4.72M4.5 18.75h9a2.25 2.25 0 002.25-2.25v-9a2.25 2.25 0 00-2.25-2.25h-9A2.25 2.25 0 002.25 7.5v9a2.25 2.25 0 002.25 2.25z" />
              </svg>
            </div>
            <div class="ml-4">
              <h3>Active Sessions</h3>
              <p class="stat-value">{@stats.active_sessions}</p>
            </div>
          </div>
        </div>

        <div class="stat-card">
          <div class="flex items-center">
            <div class="stat-card-icon bg-emerald-100 dark:bg-emerald-900/30">
              <svg class="w-6 h-6 text-emerald-600 dark:text-emerald-400" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <h3>Total Users</h3>
              <p class="stat-value">{@stats.total_users}</p>
            </div>
          </div>
        </div>

        <div class="stat-card">
          <div class="flex items-center">
            <div class="stat-card-icon bg-amber-100 dark:bg-amber-900/30">
              <svg class="w-6 h-6 text-amber-600 dark:text-amber-400" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
              </svg>
            </div>
            <div class="ml-4">
              <h3>Impersonations</h3>
              <p class="stat-value">{@stats.impersonation_sessions}</p>
            </div>
          </div>
        </div>

        <div class="stat-card">
          <div class="flex items-center">
            <div class="stat-card-icon bg-purple-100 dark:bg-purple-900/30">
              <svg class="w-6 h-6 text-purple-600 dark:text-purple-400" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 21h16.5M4.5 3h15M5.25 3v18m13.5-18v18M9 6.75h1.5m-1.5 3h1.5m-1.5 3h1.5m3-6H15m-1.5 3H15m-1.5 3H15M9 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21" />
              </svg>
            </div>
            <div class="ml-4">
              <h3>Tenants</h3>
              <p class="stat-value">{@stats.tenants}</p>
            </div>
          </div>
        </div>
      </div>

      <%# Quick Actions & Recent Sessions %>
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <%# Quick Actions %>
        <div class="card">
          <div class="card-header">
            <h2 class="text-base font-semibold text-gray-900 dark:text-white">Quick Actions</h2>
          </div>
          <div class="card-body space-y-3">
            <%= if has_role?(@current_user, "Admin") do %>
              <.link navigate="/impersonate" class="btn btn-secondary w-full justify-start">
                <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                </svg>
                Impersonate User
              </.link>
            <% end %>
            <.link navigate="/sessions/new" class="btn btn-primary w-full justify-start">
              <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
              </svg>
              New Session
            </.link>
            <.link navigate="/tenants" class="btn btn-secondary w-full justify-start">
              <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
              </svg>
              Add Tenant
            </.link>
          </div>
        </div>

        <%# Recent Sessions %>
        <div class="lg:col-span-2 card">
          <div class="card-header flex items-center justify-between">
            <h2 class="text-base font-semibold text-gray-900 dark:text-white">Recent Sessions</h2>
            <.link navigate="/sessions" class="text-sm font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400">
              View all
            </.link>
          </div>
          <div class="card-body p-0">
            <%= if @recent_sessions == [] do %>
              <div class="empty-state">
                <svg class="empty-state-icon" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 10.5l4.72-4.72a.75.75 0 011.28.53v11.38a.75.75 0 01-1.28.53l-4.72-4.72M4.5 18.75h9a2.25 2.25 0 002.25-2.25v-9a2.25 2.25 0 00-2.25-2.25h-9A2.25 2.25 0 002.25 7.5v9a2.25 2.25 0 002.25 2.25z" />
                </svg>
                <h3 class="empty-state-title">No sessions yet</h3>
                <p class="empty-state-description">Get started by creating your first session.</p>
                <.link navigate="/sessions/new" class="btn btn-primary">
                  Create Session
                </.link>
              </div>
            <% else %>
              <ul class="divide-y divide-gray-200 dark:divide-gray-700" role="list">
                <%= for session <- @recent_sessions do %>
                  <li class="px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors duration-150">
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-3">
                        <div class={"w-2 h-2 rounded-full #{if session.status == "active", do: "bg-emerald-500", else: "bg-gray-400"}"}></div>
                        <div>
                          <p class="text-sm font-medium text-gray-900 dark:text-white">{session.context}</p>
                          <p class="text-xs text-gray-500 dark:text-gray-400">
                            {Calendar.strftime(session.created_at, "%b %d, %I:%M %p")}
                          </p>
                        </div>
                      </div>
                      <.link navigate={"/sessions/#{session.id}"} class="text-sm font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400">
                        View
                      </.link>
                    </div>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
