defmodule Buzzword.Bingo.SummaryTest do
  use ExUnit.Case, async: true

  alias Buzzword.Bingo.{Game, Player, Square, Summary}

  doctest Summary

  setup_all do
    joe = Player.new("Joe", "light_blue")
    jim = Player.new("Jim", "light_cyan")

    marked_squares = [
      %Square{phrase: "A1", points: 101, marked_by: joe},
      %Square{phrase: "A2", points: 102, marked_by: nil},
      %Square{phrase: "A3", points: 103, marked_by: jim},
      %Square{phrase: "B1", points: 201, marked_by: nil},
      %Square{phrase: "B2", points: 202, marked_by: joe},
      %Square{phrase: "B3", points: 203, marked_by: nil},
      %Square{phrase: "C1", points: 301, marked_by: jim},
      %Square{phrase: "C2", points: 302, marked_by: nil},
      %Square{phrase: "C3", points: 303, marked_by: joe}
    ]

    marked_game = %Game{
      name: "marked-game",
      size: 3,
      squares: marked_squares,
      scores: %{joe => 606, jim => 404},
      winner: joe
    }

    icy_moon = Game.new("icy-moon", 5)
    bad_game = Game.new('bad-game', 4)
    games = %{icy_moon: icy_moon, bad_game: bad_game, marked_game: marked_game}
    {:ok, games: games}
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

    test "can be encoded by Poison", %{games: games} do
      assert games.marked_game |> Summary.new() |> Poison.encode!() ==
               ~s<{"winner":{"name":"Joe","color":"light_blue"},"squares":[[{"points":101,"phrase":"A1","marked_by":{"name":"Joe","color":"light_blue"}},{"points":102,"phrase":"A2","marked_by":null},{"points":103,"phrase":"A3","marked_by":{"name":"Jim","color":"light_cyan"}}],[{"points":201,"phrase":"B1","marked_by":null},{"points":202,"phrase":"B2","marked_by":{"name":"Joe","color":"light_blue"}},{"points":203,"phrase":"B3","marked_by":null}],[{"points":301,"phrase":"C1","marked_by":{"name":"Jim","color":"light_cyan"}},{"points":302,"phrase":"C2","marked_by":null},{"points":303,"phrase":"C3","marked_by":{"name":"Joe","color":"light_blue"}}]],"scores":{"Joe":{"score":606,"color":"light_blue"},"Jim":{"score":404,"color":"light_cyan"}}}>
    end
  end
end
