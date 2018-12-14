defmodule Day1Test do
  use ExUnit.Case

  doctest Day1

  test "final_frequency" do
    assert Day1.final_frequency("""
           +1
           +1
           -3
           """) == -1
  end

  test "repeated_frequency" do
    assert Day1.repeated_frequency([
             "+3\n",
             "+3\n",
             "+4\n",
             "-2\n",
             "-4\n"
           ]) == 10
  end
end
