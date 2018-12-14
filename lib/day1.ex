defmodule Day1 do
  def final_frequency(input) do
    input
    |> String.split("\n", trim: true)
    |> sum_lines(0)
  end

  def sum_lines([line | lines], acc) do
    new_acc = String.to_integer(line) + acc
    sum_lines(lines, new_acc)
  end

  def sum_lines([], acc), do: acc

  def repeated_frequency(file_stream) do
    file_stream
    |> Stream.map(fn line ->
      {integer, _leftover} = Integer.parse(line)
      integer
    end)
    |> Stream.cycle()
    |> Enum.reduce_while({0, [0]}, fn x, {current_frequency, seen_frequencies} ->
      new_frequency = x + current_frequency

      if new_frequency in seen_frequencies do
        {:halt, new_frequency}
      else
        {:cont, {new_frequency, [new_frequency | seen_frequencies]}}
      end
    end)
  end
end
