defmodule PulseboardWeb.Resolvers.User do
  @moduledoc """
  GraphQL resolvers for User queries.
  """

  def current(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def current(_parent, _args, _resolution) do
    {:error, "Not authenticated"}
  end
end
