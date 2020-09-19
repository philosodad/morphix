defmodule Morphix.Mixfile do
  use Mix.Project

  def project do
    [
      app: :morphix,
      version: "0.8.1",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp package do
    [
      name: :morphix,
      licenses: ["MIT"],
      maintainers: ["Paul Daigle"],
      links: %{"GitHub" => "https://github.com/philosodad/morphix.git"}
    ]
  end

  defp description do
    """
    Morphix is a small package of convenience methods for working with Maps, Tuples, and Lists.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:excoveralls, "~> 0.8", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev},
      {:credo, "~> 0.9.1", only: [:dev, :test]}
    ]
  end
end
