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
    size = length(squares)
    Enum.each(squares, &print_row(&1, column_width, size))
  end

  @spec print_row([Square.t()], pos_integer, pos_integer) :: :ok
  defp print_row(squares, column_width, size) do
    squares
    |> Stream.with_index(1)
    |> Enum.each(&print_square(&1, column_width, size))
  end

  @spec print_square({Square.t(), pos_integer}, pos_integer, pos_integer) :: :ok
  defp print_square({square, index}, column_width, size) do
    [
      color_of_square(square),
      text_in_square_padded(square, column_width),
      :reset,
      if(index < size, do: " | ", else: "\n")
    ]
    |> ANSI.write()
  end

  @spec color_of_square(Square.t()) :: atom | [atom]
  defp color_of_square(square) do
    case square.marked_by do
      nil -> :light_white
      player -> [:"#{player.color}_background", :stratos]
    end
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

  @spec print_scores(map) :: :ok
  defp print_scores(scores) do
    ["\n", :underline, :light_white, "Scores:", :reset, " "] |> ANSI.write()

    Enum.each(scores, fn {name, %{color: color, score: score}} ->
      [
        :"#{color}_background",
        :stratos,
        "#{name}: #{score}",
        :reset,
        " "
      ]
      |> ANSI.write()
    end)

    IO.puts("\n")
  end

  @spec print_bingo(Player.t() | nil) :: :ok
  defp print_bingo(%Player{name: name} = _winner) do
    [:gold_background, :stratos, " ⭐⭐⭐ BINGO! #{name} wins! ", :reset]
    |> ANSI.puts()
  end

  defp print_bingo(nil) do
    [:deco_background, :stratos, " 🙁  No Bingo (yet) ", :reset]
    |> ANSI.puts()
  end
end
