import Config

config :pulseboard_infra, PulseboardInfra.Repo,
  username: "pulseboard",
  password: "pulseboard_dev",
  hostname: "localhost",
  database: "pulseboard_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :pulseboard_web, PulseboardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test-only-secret-key-base-that-is-at-least-64-bytes-long-for-phoenix-to-accept-it",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
