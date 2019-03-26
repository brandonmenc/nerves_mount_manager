defmodule NervesMountManager.FstabTest do
  use ExUnit.Case

  alias NervesMountManager.Fstab

  test "parses fstab entries" do
    output =
      "test/fixtures/fstab"
      |> File.read!()
      |> Fstab.parse()

    expected =
      "test/fixtures/fstab_parsed.term"
      |> File.read!()
      |> :erlang.binary_to_term()

    assert output == expected
  end
end
