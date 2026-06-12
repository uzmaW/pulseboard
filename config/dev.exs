import Config

config :pulseboard_infra, PulseboardInfra.Repo,
  username: "pulseboard",
  password: "pulseboard_dev",
  hostname: "localhost",
  database: "pulseboard_dev#{System.get_env("MIX_TEST_PARTITION")}",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :pulseboard_web, PulseboardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev-only-secret-key-base-that-is-at-least-64-bytes-long-for-phoenix-to-accept-it",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
