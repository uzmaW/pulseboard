defmodule PulseboardWeb.Router do
  use PulseboardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PulseboardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PulseboardWeb.Plugs.FetchTenant
    plug PulseboardWeb.Plugs.FetchCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug PulseboardWeb.Plugs.FetchTenant
    plug PulseboardWeb.Plugs.FetchCurrentUser
  end

  pipeline :admin_only do
    plug PulseboardWeb.Plugs.RBAC, roles: ["Admin"]
  end

  scope "/", PulseboardWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/sessions", SessionLive, :index
    live "/sessions/:id", SessionLive, :show
    live "/impersonate", ImpersonateLive, :index
    live "/tenants", TenantFormLive, :new
  end

  scope "/impersonate", PulseboardWeb do
    pipe_through [:browser, :admin_only]

    post "/:target_user_id", ImpersonationController, :create
    delete "/", ImpersonationController, :delete
  end

  scope "/api" do
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug, schema: PulseboardWeb.Schema
    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: PulseboardWeb.Schema,
      interface: :playground
  end
end
