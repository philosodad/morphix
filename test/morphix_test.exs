defmodule MorphixTest do
  use ExUnit.Case, async: true
  require Morphix
  doctest Morphix

  test "atomorphify will atomize based on existing atoms" do
    test_map = %{
      "existing_atom" => "exists",
      "non_existent_atom" => "does_not",
      1 => "is_ignored"
    }

    expected_map = %{
      "non_existent_atom" => "does_not",
      1 => "is_ignored",
      existing_atom: "exists"
    }

    assert Morphix.atomorphify!(test_map, :safe) == expected_map
  end

  test "atomorphiform will atomize based on existing atoms" do
    test_map = %{"allowed" => "atoms", "embed" => %{"will" => "convert", "values" => "to atoms"}}

    expected_map = %{"embed" => %{"will" => "convert", values: "to atoms"}, allowed: "atoms"}

    assert Morphix.atomorphiform!(test_map, :safe) == expected_map
  end

  test "atomorphify will return map unchanged if given empty list" do
    test_map = %{
      "allowed_top_key" => "atoms",
      "embed" => %{"will" => "convert", "allowed_nested" => "to atoms"}
    }

    assert Morphix.atomorphify!(test_map, []) == test_map
  end

  test "atomorphiform will return map unchanged if given empty list" do
    test_map = %{
      "allowed_top_key" => "atoms",
      "embed" => %{"will" => "convert", "allowed_nested" => "to atoms"}
    }

    assert Morphix.atomorphiform!(test_map, []) == test_map
  end

  test "atomorphiform will atomize based on a list of allowed values" do
    test_map = %{
      "allowed_top_key" => "atoms",
      "embed" => %{"will" => "convert", "allowed_nested" => "to atoms"}
    }

    expected_map = %{
      "embed" => %{"will" => "convert", allowed_nested: "to atoms"},
      allowed_top_key: "atoms"
    }

    assert Morphix.atomorphiform!(test_map, ["allowed_top_key", "allowed_nested"]) == expected_map
  end

  test "atomorphiform will atomize embedded lists" do
    test_map = %{"this" => ["map", %{"has" => ["a", "list"]}], "inside" => "it"}
    expected_map = %{"this" => ["map", %{has: ["a", "list"]}], inside: "it"}

    assert Morphix.atomorphiform!(test_map, ["inside", "has"]) == expected_map
  end

  test "atomorphify will reject non-map parameters" do
    assert_raise(FunctionClauseError, fn -> Morphix.atomorphify("foo", ["foo", "bar"]) end)
  end

  test "atomorphify will reject second parameter that is not a list or :safe" do
    assert_raise(FunctionClauseError, fn -> Morphix.atomorphify(%{"foo" => "foo"}, :foo) end)
  end

  test "atomorphiform will reject non-map parameters" do
    assert_raise(FunctionClauseError, fn -> Morphix.atomorphiform("foo", ["foo", "bar"]) end)
  end

  test "atomorphiform will reject second parameter that is not a list or :safe" do
    assert_raise(FunctionClauseError, fn -> Morphix.atomorphiform(%{"foo" => "foo"}, :foo) end)
  end

  test "atomorphify if the list has non-binary keys" do
    assert {:ok, %{1 => "foo"}} == Morphix.atomorphify(%{1 => "foo"}, [1, 2])
  end

  test "atomorphiform will handle lists of nested maps" do
    test_map = %{
      "this" => [
        %{"map" => "has"},
        %{"an" => "inner", "list" => ["of", %{"string" => "key"}]}
      ],
      "maps" => "as well"
    }

    expected_map = %{
      this: [
        %{map: "has"},
        %{an: "inner", list: ["of", %{string: "key"}]}
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
      "the" => "other",
      "how" => %{
        the: nil,
        heck: nil,
        empty: %{empty: %{empty: %{}}, blank: nil, empte: %{sort: %{}, of: nil}}
      },
      "but" => %{
        what: %{},
        about: "this",
        deeper: %{nested: "map", that: %{}, maps: %{very: "deep", indeed: nil}, time: time}
      }
    }

    expected_map = %{
      "the" => "other",
      "this" => time,
      "but" => %{about: "this", deeper: %{nested: "map", maps: %{very: "deep"}, time: time}}
    }

    assert Morphix.compactiform(test_map) == {:ok, expected_map}
  end

  test "stringmorphiphorm will work (all allowed)" do
    time = DateTime.utc_now()

    test_map = %{
      :this => time,
      :that => nil,
      :the => "other",
      :how => %{
        heck: nil,
        empty: %{empty: %{empty: %{}}, blank: nil, empte: %{sort: %{}, of: nil}}
      }
    }

    expected_map = %{
      "this" => time,
      "that" => nil,
      "the" => "other",
      "how" => %{
        "heck" => nil,
        "empty" => %{
          "empty" => %{"empty" => %{}},
          "blank" => nil,
          "empte" => %{"sort" => %{}, "of" => nil}
        }
      }
    }

    assert Morphix.stringomorphiform!(test_map) == expected_map
  end

  test "stringmorphiphorm will work (filtering allowed)" do
    time = DateTime.utc_now()

    test_map = %{
      :this => time,
      :that => nil,
      :the => "other",
      :how => %{
        heck: nil,
        empty: %{empty: %{empty: %{}}, blank: nil, empte: %{sort: %{}, of: nil}}
      }
    }

    expected_map = %{
      "this" => time,
      "that" => nil,
      "the" => "other",
      "how" => %{
        "heck" => nil,
        :empty => %{blank: nil, empte: %{of: nil, sort: %{}}, empty: %{empty: %{}}}
      }
    }

    assert Morphix.stringomorphiform!(test_map, [:this, :that, :the, :how, :heck]) == expected_map
  end
end
