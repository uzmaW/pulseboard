defmodule PulseboardWeb.Components.ImpersonationBanner do
  @moduledoc """
  Banner component shown when an admin is impersonating a user.
  """

  use Phoenix.Component

  @doc """
  Renders the impersonation banner.
  """
  attr :impersonating?, :boolean, required: true
  attr :target_user_name, :string, required: true

  def render(assigns) do
    ~H"""
    <div :if={@impersonating?} class="impersonation-banner">
      <div class="banner-content">
        <span class="banner-text">
          You are impersonating <strong>{@target_user_name}</strong>
        </span>
        <a href="/impersonate/exit" class="banner-exit">
          Exit Impersonation
        </a>
      </div>
    </div>
    """
  end
end
