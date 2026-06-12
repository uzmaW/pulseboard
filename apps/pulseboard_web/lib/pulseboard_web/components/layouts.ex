defmodule PulseboardWeb.Layouts do
  @moduledoc """
  Layouts for the PulseBoard web application.
  """

  use PulseboardWeb, :html

  def active_nav_class(request_path, path) do
    active =
      case path do
        "/" -> request_path == "/"
        "/sessions" -> String.starts_with?(request_path, "/sessions")
        "/tenants" -> request_path == "/tenants"
        "/impersonate" -> request_path == "/impersonate"
        _ -> false
      end

    if active do
      "bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300"
    else
      "text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white hover:bg-gray-50 dark:hover:bg-gray-700"
    end
  end

  embed_templates "layouts/*"
end
