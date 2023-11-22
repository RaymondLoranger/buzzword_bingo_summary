defmodule Buzzword.Bingo.SummaryTest do
  use ExUnit.Case, async: true

  alias Buzzword.Bingo.{Game, Player, Summary}

  doctest Summary

  setup_all do
    joe = Player.new("Joe", "light_green")
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
      |> Game.mark_square("A1", joe)
      |> Game.mark_square("A3", jim)
      |> Game.mark_square("B2", joe)
      |> Game.mark_square("C1", jim)
      |> Game.mark_square("C3", joe)

    icy_moon = Game.new("icy-moon", 5)
    bad_game = Game.new(~c"bad-game", 4)
    games = %{icy_moon: icy_moon, bad_game: bad_game, won_game: won_game}
    players = %{joe: joe, jim: jim}
    %{games: games, players: players}
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

    test "has scores of a won game", %{games: games, players: players} do
      {joe, jim} = {players.joe, players.jim}

      assert Summary.new(games.won_game).scores == %{
               joe.name => %{color: joe.color, score: 606, marked: 3},
               jim.name => %{color: jim.color, score: 404, marked: 2}
             }
    end

    test "can be encoded by Jason", %{games: games} do
      assert Summary.new(games.won_game) |> Jason.encode!() ==
               ~s<{"squares":[[{"phrase":"A1","points":101,"marked_by":{"name":"Joe","color":"light_green"}},{"phrase":"A2","points":102,"marked_by":null},{"phrase":"A3","points":103,"marked_by":{"name":"Jim","color":"light_cyan"}}],[{"phrase":"B1","points":201,"marked_by":null},{"phrase":"B2","points":202,"marked_by":{"name":"Joe","color":"light_green"}},{"phrase":"B3","points":203,"marked_by":null}],[{"phrase":"C1","points":301,"marked_by":{"name":"Jim","color":"light_cyan"}},{"phrase":"C2","points":302,"marked_by":null},{"phrase":"C3","points":303,"marked_by":{"name":"Joe","color":"light_green"}}]],"scores":{"Jim":{"color":"light_cyan","score":404,"marked":2},"Joe":{"color":"light_green","score":606,"marked":3}},"winner":{"name":"Joe","color":"light_green"}}>
    end
  end
end
