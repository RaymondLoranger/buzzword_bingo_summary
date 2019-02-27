# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the course "Multi-Player Bingo" by Mike and Nicole Clark. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Buzzword.Bingo.Summary do
  use PersistConfig

  @course_ref Application.get_env(@app, :course_ref)

  @moduledoc """
  Creates a `summary` struct for the _Multi-Player Bingo_ game.
  Also writes a `summary` or `game` as a table to standard out.
  \n##### #{@course_ref}
  """

  alias __MODULE__
  alias __MODULE__.Table
  alias Buzzword.Bingo.{Game, Player, Square}

  @derive [Poison.Encoder]
  @derive Jason.Encoder
  @enforce_keys [:squares, :scores, :winner]
  defstruct [:squares, :scores, :winner]

  @type t :: %Summary{
          squares: [[Square.t()]],
          scores: %{String.t() => map},
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
  Writes the given `summary` or `game` as a table to standard out.
  """
  @spec table(Summary.t() | Game.t()) :: :ok
  defdelegate table(summary_or_game), to: Table, as: :format
end
