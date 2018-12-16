defmodule Buzzword.Bingo.Summary.MixProject do
  use Mix.Project

  def project do
    [
      app: :buzzword_bingo_summary,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:poison, "~> 3.0"},
      {:buzzword_bingo_game, path: "../buzzword_bingo_game"},
      {:buzzword_bingo_player, path: "../buzzword_bingo_player"},
      {:buzzword_bingo_square, path: "../buzzword_bingo_square"},
      {:io_ansi_plus, "~> 0.1"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
