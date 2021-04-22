defmodule Morphix.Mixfile do
  use Mix.Project

  @source_url "https://github.com/philosodad/morphix.git"
  @version "0.8.1"

  def project do
    [
      app: :morphix,
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description:
        "Morphix is a small package of convenience methods " <>
          "for working with Maps, Tuples, and Lists.",
      name: :morphix,
      licenses: ["MIT"],
      maintainers: ["Paul Daigle"],
      links: %{
        "Changelog" => "https://hexdocs.pm/morphix/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.8", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 0.9.1", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", {:"LICENSE.md", [title: "License"]}, "README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
