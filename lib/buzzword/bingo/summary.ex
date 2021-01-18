# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the course "Multi-Player Bingo" by Mike and Nicole Clark. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Buzzword.Bingo.Summary do
  @moduledoc """
  Creates a `summary` struct for the _Multi-Player Bingo_ game.
  Also writes a `summary` or `game` as a formatted table to standard out.

  ##### Based on the course [Multi-Player Bingo](https://pragmaticstudio.com/courses/unpacked-bingo) by Mike and Nicole Clark.
  """

  alias __MODULE__
  alias __MODULE__.Formatter
  alias Buzzword.Bingo.{Game, Player, Square}

  @derive [Poison.Encoder]
  @derive Jason.Encoder
  @enforce_keys [:squares, :scores, :winner]
  defstruct [:squares, :scores, :winner]

  @type player_score :: %{
          color: Player.color(),
          score: non_neg_integer,
          marked: non_neg_integer
        }
  @type score :: {Player.name(), player_score}
  @type scores :: %{Player.name() => player_score}
  @type t :: %Summary{
          squares: [[Square.t()]],
          scores: scores,
          winner: Player.t() | nil
        }

  @doc """
  Creates a `summary` from the given `game`.
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

  @doc """
  Writes the given `summary` or `game` as a formatted table to standard out.
  """
  @spec print(Summary.t() | Game.t()) :: :ok
  defdelegate print(summary_or_game), to: Formatter
end
