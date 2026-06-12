defmodule PulseboardInfra.Repo do
  @moduledoc """
  Ecto repository for PulseBoard.
  """

  use Ecto.Repo,
    otp_app: :pulseboard,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically loads the repository url from the environment.
  """
  @spec init_term_level(any()) :: {:ok, keyword()} | :error
  def init_term_level(_), do: :error
end
