use Mix.Config

config :mailerlite, key: System.get_env("MAILERLITE")

import_config "#{Mix.env}.exs"
