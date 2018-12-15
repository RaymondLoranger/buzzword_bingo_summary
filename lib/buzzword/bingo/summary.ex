# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the course "Multi-Player Bingo" by Mike and Nicole Clark. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Buzzword.Bingo.Summary do
  use PersistConfig

  @course_ref Application.get_env(@app, :course_ref)

  @moduledoc """
  Creates a `summary` struct for the _Multi-Player Bingo_ game.
  Also writes a textual representation of a `summary` to standard out.
  \n##### #{@course_ref}
  """

  alias __MODULE__
  alias __MODULE__.Table
  alias Buzzword.Bingo.{Game, Player, Square}

  @derive [Poison.Encoder]
  @enforce_keys [:squares, :scores, :winner]
  defstruct [:squares, :scores, :winner]

  @type t :: %Summary{
          squares: [[Square.t()]],
          scores: %{Player.t() => pos_integer},
          winner: Player.t() | nil
        }

  @doc """
  Creates a `summary` from the given `game`.
  """
  @spec new(Game.t()) :: t | {:error, atom}
  def new(%Game{} = game) do
    %Summary{
      squares: Enum.chunk_every(game.squares, game.size),
      scores: game.scores,
      winner: game.winner
    }
  end

  def new(_game), do: {:error, :invalid_summary_arg}

  @doc """
  Writes a textual representation of the given `summary` to standard out.
  """
  @spec table(Summary.t()) :: :ok
  defdelegate table(summary), to: Table, as: :format
end
