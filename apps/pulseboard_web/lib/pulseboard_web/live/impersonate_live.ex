defmodule PulseboardWeb.ImpersonateLive do
  @moduledoc """
  LiveView for managing impersonation sessions.
  """

  use PulseboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Impersonate User")
     |> assign(:form, to_form(%{
       "target_user_id" => "",
       "reason" => "",
       "scope" => "support"
     }))
     |> assign(:scopes, ["support", "qa", "training", "debugging"])
     |> assign(:errors, %{})
     |> assign(:active_session, nil)
     |> assign(:show_confirm_dialog, false)
     |> assign(:submitting, false)}
  end

  @impl true
  def handle_event("start_impersonation", %{"impersonation" => params}, socket) do
    socket = assign(socket, :submitting, true)

    case validate_impersonation(params) do
      {:ok, validated_params} ->
        session = %{
          id: "imp-#{System.unique_integer([:positive])}",
          target_user_id: validated_params["target_user_id"],
          reason: validated_params["reason"],
          scope: validated_params["scope"],
          started_at: DateTime.utc_now(),
          status: :active
        }

        {:noreply,
         socket
         |> assign(:active_session, session)
         |> assign(:submitting, false)
         |> assign(:errors, %{})
         |> put_flash(:info, "Impersonation session started successfully.")}

      {:error, errors} ->
        {:noreply,
         socket
         |> assign(:form, to_form(params))
         |> assign(:errors, errors)
         |> assign(:submitting, false)}
    end
  end

  def handle_event("validate", %{"impersonation" => params}, socket) do
    errors = validate_impersonation_fields(params)

    {:noreply,
     socket
     |> assign(:form, to_form(params))
     |> assign(:errors, errors)}
  end

  def handle_event("confirm_end_impersonation", _params, socket) do
    {:noreply, assign(socket, :show_confirm_dialog, true)}
  end

  def handle_event("cancel_end_impersonation", _params, socket) do
    {:noreply, assign(socket, :show_confirm_dialog, false)}
  end

  def handle_event("end_impersonation", _params, socket) do
    {:noreply,
     socket
     |> assign(:active_session, nil)
     |> assign(:show_confirm_dialog, false)
     |> put_flash(:info, "Impersonation session ended.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-6">
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">{@page_title}</h1>
        <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
          Securely impersonate a user for support, QA, or training purposes.
        </p>
      </div>

      <%# Active Session Banner %>
      <div :if={@active_session} class="impersonation-banner rounded-xl p-6 mb-6">
        <div class="flex items-start justify-between">
          <div class="flex items-start space-x-4">
            <div class="p-3 bg-amber-100 dark:bg-amber-900/30 rounded-lg">
              <svg class="w-6 h-6 text-amber-600 dark:text-amber-400" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
              </svg>
            </div>
            <div>
              <h2 class="text-lg font-semibold text-amber-800 dark:text-amber-300">Active Impersonation</h2>
              <dl class="mt-2 space-y-1">
                <div class="flex items-center space-x-2">
                  <dt class="text-sm font-medium text-amber-700 dark:text-amber-400">Target User:</dt>
                  <dd class="text-sm text-amber-900 dark:text-amber-200">{@active_session.target_user_id}</dd>
                </div>
                <div class="flex items-center space-x-2">
                  <dt class="text-sm font-medium text-amber-700 dark:text-amber-400">Reason:</dt>
                  <dd class="text-sm text-amber-900 dark:text-amber-200">{@active_session.reason}</dd>
                </div>
                <div class="flex items-center space-x-2">
                  <dt class="text-sm font-medium text-amber-700 dark:text-amber-400">Scope:</dt>
                  <dd class="text-sm text-amber-900 dark:text-amber-200">{@active_session.scope}</dd>
                </div>
                <div class="flex items-center space-x-2">
                  <dt class="text-sm font-medium text-amber-700 dark:text-amber-400">Started:</dt>
                  <dd class="text-sm text-amber-900 dark:text-amber-200">
                    {Calendar.strftime(@active_session.started_at, "%I:%M %p")}
                  </dd>
                </div>
              </dl>
            </div>
          </div>
          <button phx-click="confirm_end_impersonation" class="btn btn-danger btn-sm">
            End Session
          </button>
        </div>
      </div>

      <%# New Session Form %>
      <div :if={!@active_session} class="card">
        <div class="card-body">
          <.form for={@form} phx-submit="start_impersonation" phx-change="validate" novalidate>
            <div class="space-y-5">
              <%# Target User ID %>
              <div class="form-group">
                <label for="target_user_id" class="form-label">
                  Target User ID
                  <span class="form-required" aria-label="required">*</span>
                </label>
                <input
                  type="text"
                  name="impersonation[target_user_id]"
                  id="target_user_id"
                  value={@form[:target_user_id].value}
                  placeholder="user-123"
                  class="form-input"
                  aria-required="true"
                  aria-invalid={if @errors[:target_user_id], do: "true"}
                  aria-describedby={if @errors[:target_user_id], do: "target_user_id-error"}
                />
                <p :if={@errors[:target_user_id]} id="target_user_id-error" class="form-error" role="alert">
                  {@errors[:target_user_id]}
                </p>
                <p class="form-helper">The ID of the user you want to impersonate.</p>
              </div>

              <%# Reason %>
              <div class="form-group">
                <label for="reason" class="form-label">
                  Reason
                  <span class="form-required" aria-label="required">*</span>
                </label>
                <input
                  type="text"
                  name="impersonation[reason]"
                  id="reason"
                  value={@form[:reason].value}
                  placeholder="Support request, QA testing, training..."
                  class="form-input"
                  aria-required="true"
                  aria-invalid={if @errors[:reason], do: "true"}
                  aria-describedby={if @errors[:reason], do: "reason-error"}
                />
                <p :if={@errors[:reason]} id="reason-error" class="form-error" role="alert">
                  {@errors[:reason]}
                </p>
                <p class="form-helper">Explain why you need to impersonate this user.</p>
              </div>

              <%# Scope %>
              <div class="form-group">
                <label for="scope" class="form-label">
                  Scope
                </label>
                <select
                  name="impersonation[scope]"
                  id="scope"
                  class="form-input"
                >
                  <%= for scope <- @scopes do %>
                    <option value={scope} selected={@form[:scope].value == scope}>
                      {scope |> String.capitalize()}
                    </option>
                  <% end %>
                </select>
                <p class="form-helper">The purpose of this impersonation session.</p>
              </div>
            </div>

            <div class="mt-6 flex items-center justify-end space-x-3">
              <button
                type="submit"
                class="btn btn-primary"
                disabled={@submitting}
                aria-busy={@submitting}
              >
                <%= if @submitting do %>
                  <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Starting...
                <% else %>
                  Start Impersonation
                <% end %>
              </button>
            </div>
          </.form>
        </div>
      </div>

      <%# Confirmation Dialog %>
      <div :if={@show_confirm_dialog} class="dialog-overlay" role="dialog" aria-modal="true" aria-labelledby="confirm-dialog-title">
        <div class="dialog-content">
          <div class="flex items-center mb-4">
            <div class="p-2 bg-red-100 dark:bg-red-900/30 rounded-lg mr-3">
              <svg class="w-5 h-5 text-red-600 dark:text-red-400" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
              </svg>
            </div>
            <h3 id="confirm-dialog-title" class="dialog-title">End Impersonation?</h3>
          </div>
          <p class="dialog-description">
            Are you sure you want to end this impersonation session? The user will return to their original context.
          </p>
          <div class="dialog-actions">
            <button phx-click="cancel_end_impersonation" class="btn btn-secondary">
              Cancel
            </button>
            <button phx-click="end_impersonation" class="btn btn-danger">
              End Session
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp validate_impersonation(params) do
    errors = validate_impersonation_fields(params)

    if errors == %{} do
      {:ok, params}
    else
      {:error, errors}
    end
  end

  defp validate_impersonation_fields(params) do
    %{}
    |> then(fn errors ->
      if String.trim(params["target_user_id"] || "") == "" do
        Map.put(errors, :target_user_id, "Target user ID is required")
      else
        errors
      end
    end)
    |> then(fn errors ->
      if String.trim(params["reason"] || "") == "" do
        Map.put(errors, :reason, "Reason is required")
      else
        errors
      end
    end)
  end
end
