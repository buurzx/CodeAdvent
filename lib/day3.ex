defmodule Day3 do
  @type claim :: String.t()
  @type parsed_claim :: list
  @type coordinate :: {pos_integer, pos_integer}
  @type id :: integer

  @doc """
  Parses claims

  ## Examples

      iex> Day3.parse_claim("#1 @ 604,670: 22x16")
      [1, 604, 670, 22, 16]
  """
  @spec parse_claim(claim) :: parsed_claim
  def parse_claim(string) do
    string
    |> String.split(["#", " @ ", ",", ": ", "x"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Retrieves all claimed inches

  ## Examples

      iex> claimed = Day3.claimed_inches([
      ...>    "#1 @ 1,3: 4x4",
      ...>    "#2 @ 3,1: 4x4",
      ...>    "#3 @ 5,5: 2x2"
      ...>  ])
      iex> claimed[{4,2}]
      [2]
      iex> claimed[{4,4}]
      [2, 1]
  """
  @spec claimed_inches([claim]) :: %{coordinate => [id]}
  def claimed_inches(claims) do
    Enum.reduce(claims, %{}, fn claim, acc ->
      [id, left, top, width, height] = parse_claim(claim)

      Enum.reduce((left + 1)..(left + width), acc, fn x, acc ->
        Enum.reduce((top + 1)..(top + height), acc, fn y, acc ->
          Map.update(acc, {x, y}, [id], &[id | &1])
        end)
      end)
    end)
  end

  @doc """
  Retrieves overlapped inches

  ## Examples

      iex> Day3.overlapped_inches([
      ...>    "#1 @ 1,3: 4x4",
      ...>    "#2 @ 3,1: 4x4",
      ...>    "#3 @ 5,5: 2x2"
      ...>  ]) |> Enum.sort()
      [{4, 4}, {4, 5}, {5, 4}, {5, 5}]
  """
  @spec overlapped_inches([claim]) :: [coordinate]
  def overlapped_inches(claims) do
    for {coordinate, [_, _ | _]} <- claimed_inches(claims), do: coordinate
  end
end
