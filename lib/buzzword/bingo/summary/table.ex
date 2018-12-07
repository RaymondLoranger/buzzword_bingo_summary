defmodule Buzzword.Bingo.Summary.Table do
  @moduledoc """
  Writes a textual representation of a given `summary` to standard out.
  """

  alias Buzzword.Bingo.{Player, Square, Summary}
  alias IO.ANSI.Plus, as: ANSI

  @doc """
  Writes a textual representation of the given `summary` to standard out.
  """
  @spec format(Summary.t()) :: :ok
  def format(%Summary{} = summary) do
    print_squares(summary.squares)
    print_scores(summary.scores)
    print_bingo(summary.winner)
  end

  ## Private functions

  @spec print_squares([[Square.t()]]) :: :ok
  defp print_squares(squares) do
    IO.write("\n")
    column_width = column_width(squares)
    Enum.each(squares, &print_row(&1, column_width))
  end

  @spec print_row([Square.t()], pos_integer) :: :ok
  defp print_row(squares, column_width) do
    squares
    |> Enum.map_join(" | ", &square_in_ansi_format(&1, column_width))
    |> IO.puts()
  end

  @spec square_in_ansi_format(Square.t(), pos_integer) :: String.t()
  defp square_in_ansi_format(square, column_width) do
    [color_of_square(square), text_in_square_padded(square, column_width)]
    |> ANSI.format()
    |> IO.chardata_to_string()
  end

  @spec color_of_square(Square.t()) :: atom | [atom]
  defp color_of_square(square) do
    case square.marked_by do
      nil -> :light_white
      player -> [background_of_player(player), :stratos]
    end
  end

  @spec color_of_player(Player.t()) :: String.t()
  defp color_of_player(player) do
    case player.color do
      "#f9cedf" -> "mauve"
      "#d3c5f1" -> "blue_marguerite"
      "#acc95f" -> "green_yellow"
      "#aeeace" -> "baby_blue"
      "#96d7b9" -> "bright_turquoise"
      "#fce8bd" -> "portafino"
      "#fcd8ac" -> "melon"
      "#a4deff" -> "deep_sky_blue"
      "#" <> __ -> "orange_red"
      reg_color -> reg_color
    end
  end

  @spec background_of_player(Player.t()) :: atom
  defp background_of_player(player) do
    :"#{color_of_player(player)}_background"
  end

  @spec text_in_square_padded(Square.t(), pos_integer) :: String.t()
  defp text_in_square_padded(square, column_width) do
    square
    |> text_in_square()
    |> String.pad_trailing(column_width)
  end

  @spec text_in_square(Square.t()) :: String.t()
  defp text_in_square(square), do: "#{square.phrase} (#{square.points})"

  @spec column_width([[Square.t()]]) :: pos_integer
  defp column_width(squares) do
    squares
    |> List.flatten()
    |> Stream.map(&text_in_square/1)
    |> Stream.map(&String.length/1)
    |> Enum.max()
  end

  @spec print_scores(%{Player.t() => pos_integer}) :: :ok
  defp print_scores(scores) do
    ["\n", :underline, :light_white, "Scores", :reset, " "] |> ANSI.write()

    scores
    |> Enum.map_join(" ", fn {player, points} ->
      [background_of_player(player), :stratos, "#{player.name}: #{points}"]
      |> ANSI.format()
      |> IO.chardata_to_string()
    end)
    |> IO.puts()
  end

  @spec print_bingo(Player.t() | nil) :: :ok
  defp print_bingo(%Player{name: name} = _winner) do
    ["\n", :gold_background, :stratos, "⭐️ BINGO! #{name} wins!", :reset, "\n"]
    |> ANSI.puts()
  end

  defp print_bingo(nil) do
    ["\n", :deco_background, :stratos, "🙁  No Bingo (yet)", :reset, "\n"]
    |> ANSI.puts()
  end
end
