defmodule Buzzword.Bingo.SummaryTest do
  use ExUnit.Case, async: true

  alias Buzzword.Bingo.{Game, Player, Summary}

  doctest Summary

  setup_all do
    joe = Player.new("Joe", "light_blue")
    jim = Player.new("Jim", "light_cyan")

    won_game =
      Game.new("won-game", 3, [
        {"A1", 101},
        {"A2", 102},
        {"A3", 103},
        {"B1", 201},
        {"B2", 202},
        {"B3", 203},
        {"C1", 301},
        {"C2", 302},
        {"C3", 303}
      ])
      |> Game.mark("A1", joe)
      |> Game.mark("A3", jim)
      |> Game.mark("B2", joe)
      |> Game.mark("C1", jim)
      |> Game.mark("C3", joe)

    icy_moon = Game.new("icy-moon", 5)
    bad_game = Game.new('bad-game', 4)
    games = %{icy_moon: icy_moon, bad_game: bad_game, won_game: won_game}
    players = %{joe: joe, jim: jim}
    {:ok, games: games, players: players}
  end

  describe "Summary.new/1" do
    test "returns a struct", %{games: games} do
      assert %Summary{squares: squares, scores: %{}, winner: nil} =
               Summary.new(games.icy_moon)

      assert is_list(squares) and length(squares) == games.icy_moon.size
    end

    test "returns a struct in a `with` macro", %{games: games} do
      assert(
        %Summary{squares: _squares, scores: %{}, winner: nil} =
          with %Summary{} = summary <- Summary.new(games.icy_moon) do
            summary
          end
      )
    end

    test "returns a tuple", %{games: games} do
      assert Summary.new(games.bad_game) == {:error, :invalid_summary_arg}
    end

    test "returns a tuple in a `with` macro", %{games: games} do
      assert(
        with %Summary{} = summary <- Summary.new(games.bad_game) do
          summary
        else
          error -> error
        end == {:error, :invalid_summary_arg}
      )
    end

    test "scores of a won game", %{games: games, players: players} do
      {joe, jim} = {players.joe, players.jim}

      assert Summary.new(games.won_game).scores == %{
               joe.name => %{color: joe.color, score: 606, marked: 3},
               jim.name => %{color: jim.color, score: 404, marked: 2}
             }
    end

    test "can be encoded by Poison", %{games: games} do
      assert games.won_game |> Summary.new() |> Poison.encode!() ==
               ~s<{"winner":{"name":"Joe","color":"light_blue"},"squares":[[{"points":101,"phrase":"A1","marked_by":{"name":"Joe","color":"light_blue"}},{"points":102,"phrase":"A2","marked_by":null},{"points":103,"phrase":"A3","marked_by":{"name":"Jim","color":"light_cyan"}}],[{"points":201,"phrase":"B1","marked_by":null},{"points":202,"phrase":"B2","marked_by":{"name":"Joe","color":"light_blue"}},{"points":203,"phrase":"B3","marked_by":null}],[{"points":301,"phrase":"C1","marked_by":{"name":"Jim","color":"light_cyan"}},{"points":302,"phrase":"C2","marked_by":null},{"points":303,"phrase":"C3","marked_by":{"name":"Joe","color":"light_blue"}}]],"scores":{"Joe":{"score":606,"marked":3,"color":"light_blue"},"Jim":{"score":404,"marked":2,"color":"light_cyan"}}}>
    end

    test "can be encoded by Jason", %{games: games} do
      assert games.won_game |> Summary.new() |> Jason.encode!() ==
               ~s<{"scores":{"Jim":{"color":"light_cyan","marked":2,"score":404},"Joe":{"color":"light_blue","marked":3,"score":606}},"squares":[[{"marked_by":{"color":"light_blue","name":"Joe"},"phrase":"A1","points":101},{"marked_by":null,"phrase":"A2","points":102},{"marked_by":{"color":"light_cyan","name":"Jim"},"phrase":"A3","points":103}],[{"marked_by":null,"phrase":"B1","points":201},{"marked_by":{"color":"light_blue","name":"Joe"},"phrase":"B2","points":202},{"marked_by":null,"phrase":"B3","points":203}],[{"marked_by":{"color":"light_cyan","name":"Jim"},"phrase":"C1","points":301},{"marked_by":null,"phrase":"C2","points":302},{"marked_by":{"color":"light_blue","name":"Joe"},"phrase":"C3","points":303}]],"winner":{"color":"light_blue","name":"Joe"}}>
    end
  end
end
