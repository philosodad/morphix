defmodule MorphixTest do
  use ExUnit.Case, async: true
  require Morphix
  doctest Morphix

  test "atomorphiform will handle lists of nested maps" do
    test_map = %{
                  "this" =>
                    [
                      %{"map" => "has"},
                      %{"an" => "inner",
                      "list" =>
                        ["of",
                          %{"string" => "key"}
                        ]
                      }
                    ],
                  "maps" => "as well"
                }
    expected_map = %{
                      this:
                        [
                          %{map: "has"},
                          %{an: "inner",
                            list:
                            ["of",
                              %{string: "key"}
                            ]
                          }
                        ],
                      maps: "as well"
                    }
    assert Morphix.atomorphiform(test_map) == {:ok, expected_map}
  end

  test "compactiform will ignore structs" do
    time = DateTime.utc_now()
    test_map = %{
                  "this" => time,
                  "that" => nil,
                  "the" => "other"
                }
    expected_map = %{"the" => "other", "this" => time}
    assert Morphix.compactiform(test_map) == {:ok, expected_map}
  end
end
