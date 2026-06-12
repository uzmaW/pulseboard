defmodule PulseboardCompliance.MixProject do
  use Mix.Project

  def project do
    [
      app: :pulseboard_compliance,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        credo: :dev,
        dialyzer: :dev
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:pulseboard_core, in_umbrella: true},
      {:jason, "~> 1.4"},
      {:telemetry, "~> 1.2"}
    ]
  end
end
