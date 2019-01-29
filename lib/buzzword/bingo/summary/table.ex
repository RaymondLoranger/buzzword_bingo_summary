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
    print_scores(summary.scores, length(summary.squares))
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
    |> Enum.with_index(1)
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
      player -> [:"#{adapt(player.color)}_background", :stratos]
    end
  end

  @spec adapt(color :: String.t()) :: adapted_color :: String.t()
  def adapt("#a4deff"), do: "aqua"
  def adapt("rgb(164, 222, 255)"), do: "aqua"
  def adapt("#f9cedf"), do: "orchid"
  def adapt("rgb(249, 206, 223)"), do: "orchid"
  def adapt("#d3c5f1"), do: "moon_raker"
  def adapt("rgb(211, 197, 241)"), do: "moon_raker"
  def adapt("#acc9f5"), do: "malibu"
  def adapt("rgb(172, 201, 245)"), do: "malibu"
  def adapt("#aeeace"), do: "pale_green"
  def adapt("rgb(174, 234, 206)"), do: "pale_green"
  def adapt("#96d7b9"), do: "bondi_blue"
  def adapt("rgb(150, 215, 185)"), do: "bondi_blue"
  def adapt("#fce8bd"), do: "canary"
  def adapt("rgb(252, 232, 189)"), do: "canary"
  def adapt("#fcd8ac"), do: "dandelion"
  def adapt("rgb(252, 216, 172)"), do: "dandelion"
  def adapt(color), do: color

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
    |> Enum.map(&text_in_square/1)
    |> Enum.map(&String.length/1)
    |> Enum.max()
  end

  @spec print_scores(map, non_neg_integer) :: :ok
  defp print_scores(scores, size) do
    ["\n", :underline, :light_white, "Scores:", :reset, " "] |> ANSI.write()

    scores
    |> Enum.sort()
    |> Enum.chunk_every(size)
    |> Enum.each(&print_score_chunk/1)

    scores |> map_size() |> skip() |> IO.write()
  end

  @spec skip(non_neg_integer) :: String.t()
  defp skip(0 = _size), do: "\n\n"
  defp skip(_size), do: "\n"

  @spec print_score_chunk(score_chunk :: [tuple]) :: :ok
  defp print_score_chunk(scores) do
    Enum.each(scores, &print_score/1)
    IO.write("\n        ")
  end

  @spec print_score(score :: tuple) :: :ok
  defp print_score({name, %{color: color, score: score, marked: marked}}) do
    [
      :"#{adapt(color)}_background",
      :stratos,
      "#{name}: #{score} (#{marked} square#{(marked == 1 && "") || "s"})",
      :reset,
      "\t"
    ]
    |> ANSI.write()
  end

  @spec print_bingo(Player.t() | nil) :: :ok
  defp print_bingo(%Player{name: name} = _winner) do
    [:gold_background, :stratos, " ⭐⭐⭐ BINGO! #{name} wins! ", :reset]
    |> ANSI.puts()
  end

  defp print_bingo(nil) do
    # [:deco_background, :stratos, " 🙁  No Bingo (yet) ", :reset]
    [:deco_background, :stratos, " ☹ No Bingo (yet) ", :reset]
    |> ANSI.puts()
  end
end
