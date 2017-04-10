defmodule MailerLite.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @github  "https://github.com/nathanhornby/mailerlite-elixir"

  def project do
    [app: :mailerlite,
     name: "MailerLite",
     version: @version,
     elixir: "~> 1.4",
     source_url: @github,
     package: package(),
     description: description(),
     docs: [
       source_ref: "v#{@version}",
       main: "readme",
       extras: ["README.md"]
       ],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :httpoison]]
  end

  defp description do
    """
    **WORK IN PROGRESS - NOT READY FOR PRODUCTION USE, CHECK BACK SOON**
    
    An Elixir wrapper for v2 of the MailerLite API.
    """
  end

  defp package do
    [maintainers: ["Nathan Hornby"],
     licenses: ["MIT"],
     links: %{"GitHub" => @github,
              "Docs"   => "https://hexdocs.pm/mailerlite"}]
  end

  defp deps do
    [{:httpoison, "~> 0.11.1"},
     {:poison, "~> 3.0"},
     {:credo, "~> 0.7", only: [:dev, :test]},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end
end
