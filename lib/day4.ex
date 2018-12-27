defmodule FrequencyMap do
  defstruct data: %{}

  def new do
    %FrequencyMap{}
  end

  def most_frequent(%FrequencyMap{data: data}) do
    {key, _} = Enum.max_by(data, fn {_, count} -> count end)
    key
  end

  defimpl Collectable do
    def into(%FrequencyMap{data: data}) do
      collector_fun = fn
        data, {:cont, elem} -> Map.update(data, elem, 1, &(&1 + 1))
        data, :done -> %FrequencyMap{data: data}
        _, :halt -> :ok
      end

      {data, collector_fun}
    end
  end
end

defmodule Day4 do
  import NimbleParsec

  guard_command =
    ignore(string("Guard #"))
    |> unwrap_and_tag(integer(min: 1), :shift)
    |> ignore(string(" begins shift"))

  asleep_command = string("falls asleep") |> replace(:down)
  wake_command = string("wakes up") |> replace(:up)

  defparsecp :parsec_log,
             ignore(string("["))
             |> integer(4)
             |> ignore(string("-"))
             |> integer(2)
             |> ignore(string("-"))
             |> integer(2)
             |> ignore(string(" "))
             |> integer(2)
             |> ignore(string(":"))
             |> integer(2)
             |> ignore(string("] "))
             |> choice([guard_command, asleep_command, wake_command])

  @doc """
  Parses the log.

      iex> Day4.parse_log("[1518-11-01 00:00] Guard #10 begins shift")
      {{1518, 11, 01}, 00, 00, {:shift, 10}}

      iex> Day4.parse_log("[1518-11-01 00:00] falls asleep")
      {{1518, 11, 01}, 00, 00, :down}

      iex> Day4.parse_log("[1518-11-01 00:00] wakes up")
      {{1518, 11, 01}, 00, 00, :up}
  """

  def parse_log(string) when is_binary(string) do
    {:ok, [year, month, day, hour, minute, id], "", _, _, _} = parsec_log(string)

    {{year, month, day}, hour, minute, id}
  end

  @doc """
  Groups unsorted log entries by id and date

      iex> Day4.group_by_id_and_date(
      ...>[
      ...>  "[1518-11-01 00:00] Guard #10 begins shift",
      ...>  "[1518-11-01 00:05] falls asleep",
      ...>  "[1518-11-01 00:25] wakes up",
      ...>  "[1518-11-01 00:30] falls asleep",
      ...>  "[1518-11-01 00:55] wakes up",
      ...>  "[1518-11-01 23:58] Guard #99 begins shift",
      ...>  "[1518-11-02 00:40] falls asleep",
      ...>  "[1518-11-02 00:50] wakes up",
      ...>  "[1518-11-03 00:05] Guard #10 begins shift",
      ...>  "[1518-11-03 00:24] falls asleep",
      ...>  "[1518-11-03 00:29] wakes up",
      ...>  "[1518-11-04 00:02] Guard #99 begins shift",
      ...>  "[1518-11-04 00:36] falls asleep",
      ...>  "[1518-11-04 00:46] wakes up",
      ...>  "[1518-11-05 00:03] Guard #99 begins shift",
      ...>  "[1518-11-05 00:45] falls asleep",
      ...>  "[1518-11-05 00:55] wakes up"
      ...>])
      [
        {10, {1518, 11, 1}, [5..24, 30..54]},
        {99, {1518, 11, 1}, [40..49]},
        {10, {1518, 11, 3}, [24..28]},
        {99, {1518, 11, 4}, [36..45]},
        {99, {1518, 11, 5}, [45..54]},
      ]
  """

  def group_by_id_and_date(unsortered_logs_as_strings) do
    unsortered_logs_as_strings
    |> Enum.map(&parse_log/1)
    |> Enum.sort()
    |> group_by_id_and_date([])
  end

  defp group_by_id_and_date([{date, _, _, {:shift, id}} | rest], groups) do
    {rest, ranges} = get_asleep_ranges(rest, [])
    group_by_id_and_date(rest, [{id, date, ranges} | groups])
  end

  defp group_by_id_and_date([], groups) do
    Enum.reverse(groups)
  end

  defp get_asleep_ranges(
         [{_, _, down_minute, :down}, {_, _, up_minute, :up} | rest],
         ranges
       ) do
    get_asleep_ranges(rest, [down_minute..(up_minute - 1) | ranges])
  end

  defp get_asleep_ranges(rest, ranges) do
    {rest, Enum.reverse(ranges)}
  end

  @doc """
  Sums the asleep times from grouped entries.

      iex> Day4.sum_asleep_times_by_id([
      ...>  {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>  {99, {1518, 11, 1}, [40..49]},
      ...>  {10, {1518, 11, 3}, [24..28]},
      ...>  {99, {1518, 11, 4}, [36..45]},
      ...>  {99, {1518, 11, 5}, [45..54]},
      ...>])
      %{
        99 => 30,
        10=> 50,
      }
  """

  def sum_asleep_times_by_id(grouped_entries) do
    Enum.reduce(grouped_entries, %{}, fn {id, _date, ranges}, acc ->
      time_asleep = ranges |> Enum.map(&Enum.count/1) |> Enum.sum()
      Map.update(acc, id, time_asleep, &(&1 + time_asleep))
    end)
  end

  @doc """
  Gets the id that is asleep the most

      iex> Day4.id_asleep_the_most(%{99=>30, 10=>50})
      10
  """
  def id_asleep_the_most(map) do
    {id, _} = Enum.max_by(map, fn {_, time_asleep} -> time_asleep end)
    id
  end

  @doc """
  Gets the id that is asleep the most
      iex> Day4.minutes_asleep_the_most_by_id([
      ...>  {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>  {99, {1518, 11, 1}, [40..49]},
      ...>  {10, {1518, 11, 3}, [24..28]},
      ...>  {99, {1518, 11, 4}, [36..45]},
      ...>  {99, {1518, 11, 5}, [45..54]},
      ...>], 10)
      24
  """
  def minutes_asleep_the_most_by_id(list, id) do
    frequency_map =
      for {^id, _, ranges} <- list,
          range <- ranges,
          minute <- range,
          do: minute,
          into: FrequencyMap.new()

    FrequencyMap.most_frequent(frequency_map)
  end

  def part1(input) do
    grouped_entries =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> group_by_id_and_date()

    id_asleep_the_most =
      grouped_entries
      |> sum_asleep_times_by_id()
      |> id_asleep_the_most()

    minute_asleep_the_most = minutes_asleep_the_most_by_id(grouped_entries, id_asleep_the_most)

    id_asleep_the_most * minute_asleep_the_most
  end
end
