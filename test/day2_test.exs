defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  test "count_characters" do
    assert Day2.count_characters("aavvcc") == %{
             ?a => 2,
             ?v => 2,
             ?c => 2
           }

    assert Day2.count_characters("aavvёё") == %{
             ?a => 2,
             ?v => 2,
             ?ё => 2
           }
  end

  test "checksum" do
    assert Day2.checksum([
             "abcdef",
             "bababc",
             "abbcde",
             "abcccd",
             "aabcdd",
             "abcdee",
             "ababab"
           ]) == 12
  end

  test 'closest' do
    assert Day2.closest([
             "abcde",
             "fghij",
             "klmno",
             "pqrst",
             "fguij",
             "axcye",
             "wvxyz"
           ]) == "fgij"
  end
end
