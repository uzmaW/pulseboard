defmodule PulseboardWeb.TenantFormLive do
  @moduledoc """
  LiveView for creating new tenants.
  """

  use PulseboardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Tenant")
     |> assign(:form, to_form(%{
       "name" => "",
       "region" => "US",
       "domain" => "",
       "admin_user_id" => ""
     }))
     |> assign(:regions, ["US", "EU", "APAC", "Global"])
     |> assign(:errors, %{})
     |> assign(:success, false)
     |> assign(:submitting, false)}
  end

  @impl true
  def handle_event("submit", %{"tenant" => params}, socket) do
    socket = assign(socket, :submitting, true)

    case validate_tenant(params) do
      {:ok, _validated_params} ->
        {:noreply,
         socket
         |> assign(:success, true)
         |> assign(:submitting, false)
         |> assign(:errors, %{})
         |> put_flash(:info, "Tenant created successfully! Onboarding has started.")}

      {:error, errors} ->
        {:noreply,
         socket
         |> assign(:form, to_form(params))
         |> assign(:errors, errors)
         |> assign(:submitting, false)}
    end
  end

  def handle_event("validate", %{"tenant" => params}, socket) do
    errors = validate_tenant_fields(params)

    {:noreply,
     socket
     |> assign(:form, to_form(params))
     |> assign(:errors, errors)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-6">
        <.link navigate="/tenants" class="inline-flex items-center text-sm font-medium text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 mb-2">
          <svg class="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
          </svg>
          Back to Tenants
        </.link>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">{@page_title}</h1>
        <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
          Create a new tenant organization with regional compliance settings.
        </p>
      </div>

      <div :if={@success} class="flash flash-success mb-6">
        <div class="flex items-center">
          <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Tenant created successfully! Onboarding has started.</span>
        </div>
      </div>

      <div class="card">
        <div class="card-body">
          <.form for={@form} phx-submit="submit" phx-change="validate" novalidate>
            <div class="space-y-5">
              <%# Tenant Name %>
              <div class="form-group">
                <label for="name" class="form-label">
                  Tenant Name
                  <span class="form-required" aria-label="required">*</span>
                </label>
                <input
                  type="text"
                  name="tenant[name]"
                  id="name"
                  value={@form[:name].value}
                  placeholder="Acme Corp"
                  class="form-input"
                  aria-required="true"
                  aria-invalid={if @errors[:name], do: "true"}
                  aria-describedby={if @errors[:name], do: "name-error"}
                />
                <p :if={@errors[:name]} id="name-error" class="form-error" role="alert">
                  {@errors[:name]}
                </p>
                <p class="form-helper">The display name for this tenant organization.</p>
              </div>

              <%# Region %>
              <div class="form-group">
                <label for="region" class="form-label">
                  Region
                  <span class="form-required" aria-label="required">*</span>
                </label>
                <select
                  name="tenant[region]"
                  id="region"
                  class="form-input"
                  aria-required="true"
                >
                  <%= for region <- @regions do %>
                    <option value={region} selected={@form[:region].value == region}>{region}</option>
                  <% end %>
                </select>
                <p class="form-helper">Determines data residency and compliance policies.</p>
              </div>

              <%# Domain %>
              <div class="form-group">
                <label for="domain" class="form-label">
                  Domain
                  <span class="form-required" aria-label="required">*</span>
                </label>
                <input
                  type="text"
                  name="tenant[domain]"
                  id="domain"
                  value={@form[:domain].value}
                  placeholder="acme.pulseboard.dev"
                  class="form-input"
                  aria-required="true"
                  aria-invalid={if @errors[:domain], do: "true"}
                  aria-describedby={if @errors[:domain], do: "domain-error"}
                />
                <p :if={@errors[:domain]} id="domain-error" class="form-error" role="alert">
                  {@errors[:domain]}
                </p>
                <p class="form-helper">Unique subdomain for tenant isolation (e.g., acme.pulseboard.dev).</p>
              </div>

              <%# Admin User ID %>
              <div class="form-group">
                <label for="admin_user_id" class="form-label">
                  Admin User ID
                  <span class="form-required" aria-label="required">*</span>
                </label>
                <input
                  type="text"
                  name="tenant[admin_user_id]"
                  id="admin_user_id"
                  value={@form[:admin_user_id].value}
                  placeholder="user-1"
                  class="form-input"
                  aria-required="true"
                  aria-invalid={if @errors[:admin_user_id], do: "true"}
                  aria-describedby={if @errors[:admin_user_id], do: "admin_user_id-error"}
                />
                <p :if={@errors[:admin_user_id]} id="admin_user_id-error" class="form-error" role="alert">
                  {@errors[:admin_user_id]}
                </p>
                <p class="form-helper">The user ID of the tenant administrator.</p>
              </div>
            </div>

            <div class="mt-6 flex items-center justify-end space-x-3">
              <.link navigate="/tenants" class="btn btn-secondary">
                Cancel
              </.link>
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
                  Creating...
                <% else %>
                  Create Tenant
                <% end %>
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  defp validate_tenant(params) do
    errors = validate_tenant_fields(params)

    if errors == %{} do
      {:ok, params}
    else
      {:error, errors}
    end
  end

  defp validate_tenant_fields(params) do
    %{}
    |> then(fn errors ->
      if String.trim(params["name"] || "") == "" do
        Map.put(errors, :name, "Tenant name is required")
      else
        errors
      end
    end)
    |> then(fn errors ->
      if String.trim(params["domain"] || "") == "" do
        Map.put(errors, :domain, "Domain is required")
      else
        errors
      end
    end)
    |> then(fn errors ->
      if String.trim(params["admin_user_id"] || "") == "" do
        Map.put(errors, :admin_user_id, "Admin user ID is required")
      else
        errors
      end
    end)
  end
end
