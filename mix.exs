defmodule Buzzword.Bingo.Summary.MixProject do
  use Mix.Project

  def project do
    [
      app: :buzzword_bingo_summary,
      version: "0.1.34",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "Buzzword Bingo Summary",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/buzzword_bingo_summary"
  end

  defp description do
    """
    A summary struct and functions for the _Multi-Player Buzzword Bingo_ game.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:buzzword_bingo_game, "~> 0.1"},
      {:buzzword_bingo_player, "~> 0.1"},
      {:buzzword_bingo_square, "~> 0.1"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:io_ansi_plus, "~> 0.1"},
      {:jason, "~> 1.0"},
      {:poison, "~> 5.0"}
    ]
  end
end
