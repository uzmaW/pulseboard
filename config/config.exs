import Config

config :pulseboard,
  ecto_repos: [PulseboardInfra.Repo]

config :pulseboard, PulseboardInfra.Repo,
  migration_primary_key: [type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

config :logger, :console,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:request_id, :tenant_id, :user_id]

config :phoenix, :json_library, Jason

config :pulseboard, :generators,
  context_app: :pulseboard_core

config :esbuild,
  version: "0.21.5",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../apps/pulseboard_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.4.3",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/pulseboard_web/assets", __DIR__)
  ]

import_config "#{config_env()}.exs"
