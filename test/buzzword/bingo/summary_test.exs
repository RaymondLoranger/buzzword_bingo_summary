defmodule Buzzword.Bingo.SummaryTest do
  use ExUnit.Case, async: true

  alias Buzzword.Bingo.{Game, Summary}

  doctest Summary

  setup_all do
    icy_moon = Game.new("icy-moon", 5)
    dark_sun = Game.new("dark-sun", 4)
    bad_game = Game.new('bad-game', 4)
    games = %{icy_moon: icy_moon, dark_sun: dark_sun, bad_game: bad_game}
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
        %Summary{squares: squares, scores: %{}, winner: nil} =
          with %Summary{} = summary <- Summary.new(games.dark_sun) do
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
  end
end
