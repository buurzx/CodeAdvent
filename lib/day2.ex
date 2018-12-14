defmodule Day2 do
  def closest(list) when is_list(list) do
    list
    |> Enum.map(&String.to_charlist/1)
    |> closest_charlists()
  end

  def closest_charlists([head | tail]) do
    Enum.find_value(tail, &one_char_diff(&1, head)) || closest_charlists(tail)
  end

  defp one_char_diff(charlist1, charlist2) do
    one_char_diff(charlist1, charlist2, [], 0)
  end

  defp one_char_diff([head | tail1], [head | tail2], acc, diff_count) do
    one_char_diff(tail1, tail2, [head | acc], diff_count)
  end

  defp one_char_diff([_ | tail1], [_ | tail2], acc, diff_count) do
    one_char_diff(tail1, tail2, acc, diff_count + 1)
  end

  defp one_char_diff([], [], acc, 1) do
    acc |> Enum.reverse() |> List.to_string()
  end

  defp one_char_diff([], [], _, _) do
    nil
  end

  def checksum(list) when is_list(list) do
    {twices, thrices} =
      Enum.reduce(list, {0, 0}, fn box_id, {total_twice, total_thrice} ->
        {twice, thrice} = box_id |> count_characters() |> get_twice_and_thrice()
        {twice + total_twice, thrice + total_thrice}
      end)

    twices * thrices
  end

  def get_twice_and_thrice(chars) when is_map(chars) do
    Enum.reduce(chars, {0, 0}, fn
      {_codepoint, 2}, {_twice, thrice} -> {1, thrice}
      {_codepoint, 3}, {twice, _thrice} -> {twice, 1}
      _, acc -> acc
    end)
  end

  def count_characters(string) when is_binary(string) do
    count_characters(string, %{})
  end

  defp count_characters(<<codepoint::utf8, rest::binary>>, acc) do
    acc = Map.update(acc, codepoint, 1, &(&1 + 1))
    count_characters(rest, acc)
  end

  defp count_characters(<<>>, acc), do: acc
end
