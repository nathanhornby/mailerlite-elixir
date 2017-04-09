use Mix.Config

# Application.get_env(:mailerlite, :key)
config :mailerlite, key: System.get_env("MAILERLITE")

import_config "#{Mix.env}.exs"
