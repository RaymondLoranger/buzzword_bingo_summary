# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the course "Multi-Player Bingo" by Mike and Nicole Clark. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Buzzword.Bingo.Summary do
  @moduledoc """
  A summary struct and functions for the _Multi-Player Bingo_ game.

  The summary struct contains the fields `squares`, `scores` and `winner`
  representing the characteristics of a summary in the _Multi-Player Bingo_
  game.

  ##### Based on the course [Multi-Player Bingo](https://pragmaticstudio.com/courses/unpacked-bingo) by Mike and Nicole Clark.
  """

  alias __MODULE__
  alias __MODULE__.Formatter
  alias Buzzword.Bingo.{Game, Player, Square}

  @derive [Poison.Encoder]
  @derive Jason.Encoder
  @enforce_keys [:squares, :scores, :winner]
  defstruct [:squares, :scores, :winner]

  @typedoc "A map of player attributes"
  @type player_score :: %{
          color: Player.color(),
          score: Game.points_sum(),
          marked: Game.marked_count()
        }
  @typedoc "A tuple of player name and player score"
  @type score :: {Player.name(), player_score}
  @typedoc "A serializable map assigning player scores to player names"
  @type scores :: %{Player.name() => player_score}
  @typedoc "A summary struct for the Multi-Player Bingo game"
  @type t :: %Summary{
          squares: [[Square.t()]],
          scores: scores,
          winner: Player.t() | nil
        }

  @doc """
  Creates a summary struct from the given `game`.
  """
  @spec new(Game.t()) :: t | {:error, atom}
  def new(%Game{} = game) do
    %Summary{
      squares: Enum.chunk_every(game.squares, game.size),
      # Can translate to a serializable JSON value...
      scores:
        Map.new(game.scores, fn {player, {score, marked}} ->
          {player.name, %{color: player.color, score: score, marked: marked}}
        end),
      winner: game.winner
    }
  end

  def new(_game), do: {:error, :invalid_summary_arg}

  @spec print(Summary.t() | Game.t()) :: :ok
  defdelegate print(summary_or_game), to: Formatter
end
