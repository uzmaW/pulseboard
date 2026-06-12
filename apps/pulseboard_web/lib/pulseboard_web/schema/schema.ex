defmodule PulseboardWeb.Schema do
  @moduledoc """
  Absinthe GraphQL schema for PulseBoard.
  """

  use Absinthe.Schema

  import_types Absinthe.Type.Custom

  alias PulseboardWeb.Resolvers

  query do
    @desc "Get a session by ID"
    field :session, :session do
      arg :id, non_null(:id)
      resolve &Resolvers.Session.get/3
    end

    @desc "List all sessions for the current tenant"
    field :sessions, list_of(:session) do
      resolve &Resolvers.Session.list/3
    end

    @desc "Get the current user"
    field :current_user, :user do
      resolve &Resolvers.User.current/3
    end
  end

  mutation do
    @desc "Start an impersonation session"
    field :start_impersonation, :impersonation_session do
      arg :target_user_id, non_null(:id)
      arg :reason, non_null(:string)
      arg :scope, :string, default_value: "support"
      resolve &Resolvers.Impersonation.start/3
    end

    @desc "End an impersonation session"
    field :end_impersonation, :impersonation_session do
      arg :session_id, non_null(:id)
      resolve &Resolvers.Impersonation.end_session/3
    end

    @desc "Assign a role to a user"
    field :assign_role, :assignment do
      arg :user_id, non_null(:id)
      arg :role_id, non_null(:id)
      arg :tenant_id, non_null(:id)
      resolve &Resolvers.RBAC.assign_role/3
    end

    @desc "Create a new session"
    field :create_session, :session do
      arg :context, non_null(:string)
      arg :context_id, :id
      arg :mode, :string, default_value: "call"
      resolve &Resolvers.Session.create/3
    end
  end

  object :session do
    field :id, non_null(:id)
    field :tenant_id, non_null(:id)
    field :participants, list_of(:participant)
    field :context, non_null(:string)
    field :context_id, :id
    field :mode, non_null(:string)
    field :status, non_null(:string)
    field :recording_url, :string
    field :transcript, :string
    field :started_at, :datetime
    field :ended_at, :datetime
  end

  object :participant do
    field :user_id, non_null(:id)
    field :role, non_null(:string)
    field :joined_at, :datetime
    field :left_at, :datetime
  end

  object :impersonation_session do
    field :id, non_null(:id)
    field :tenant_id, non_null(:id)
    field :admin_id, non_null(:id)
    field :target_user_id, non_null(:id)
    field :reason, non_null(:string)
    field :scope, non_null(:string)
    field :started_at, :datetime
    field :ended_at, :datetime
    field :status, non_null(:string)
  end

  object :user do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :email, non_null(:string)
    field :roles, list_of(:role)
  end

  object :role do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :permissions, list_of(:string)
  end

  object :assignment do
    field :id, non_null(:id)
    field :user_id, non_null(:id)
    field :role_id, non_null(:id)
    field :tenant_id, non_null(:id)
    field :assigned_at, :datetime
  end
end
