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

  describe "equaliform?" do
    setup do
      list1 = [
        1,
        ["two", "three", "four"],
        %{response: {:ok, true}, a: "one", d: [1, 2, 3], e: "five"},
        %{response: {:ok, true}, a: 1, e: 5},
        "six",
        [f: %{g: 7, h: 8, i: 9}, j: 10],
        {:error, false}
      ]

      keyword_list1 = [
        a: 1,
        b: ["two", "three", "four"],
        c: %{response: {:ok, true}, a: "one", e: "five"},
        d: %{response: {:ok, true}, a: 1, e: 5},
        e: "six",
        f: [f: %{g: 7, h: 8, i: 9}, j: 10],
        g: {:error, false}
      ]

      {:ok, list1: list1, keyword_list1: keyword_list1}
    end

    test "will return true for equal unordered elements", context do
      list2 = [
        ["three", "four", "two"],
        %{e: 5, response: {:ok, true}, a: 1},
        [j: 10, f: %{g: 7, i: 9, h: 8}],
        {:error, false},
        "six",
        %{response: {:ok, true}, a: "one", e: "five", d: [3, 2, 1]},
        1
      ]

      keyword_list2 = [
        b: ["three", "four", "two"],
        d: %{e: 5, response: {:ok, true}, a: 1},
        f: [j: 10, f: %{i: 9, g: 7, h: 8}],
        g: {:error, false},
        e: "six",
        c: %{a: "one", response: {:ok, true}, e: "five"},
        a: 1
      ]

      assert Morphix.equaliform?(context.list1, list2) == true
      assert Morphix.equaliform?(context.keyword_list1, keyword_list2) == true

      assert Morphix.equaliform?([1, 2, [3, 4, 5]], [1, 2, [3, 5, 4]]) == true

      assert Morphix.equaliform?(%{a: [1, 2, 3], b: [1, 2, 3]}, %{a: [1, 2, 3], b: [3, 2, 1]}) ==
               true

      assert Morphix.equaliform?(
               {123, :ok, true, %{a: [4, 5, 6]}},
               {true, :ok, 123, %{a: [5, 4, 6]}}
             ) == true
    end

    test "will return false for unequal unordered elements with nested values", context do
      list2 = [
        ["three", "four", "two"],
        %{e: 6, response: {:ok, true}, a: 1},
        [j: 10, f: %{g: 7, i: 9, h: 8}],
        {:error, false},
        "six",
        %{response: {:ok, true}, a: "one", e: "five", d: [3, 2, 1]},
        1
      ]

      keyword_list2 = [
        b: ["three", "four", "two"],
        d: %{e: 5, response: {:ok, true}, a: 1},
        f: [j: 10, f: %{g: 7, h: 8, i: 2}],
        g: {:error, false},
        e: "six",
        c: %{response: {:ok, true}, a: "one", e: "five"},
        a: 1
      ]

      assert Morphix.equaliform?(context.list1, list2) == false
      assert Morphix.equaliform?(context.keyword_list1, keyword_list2) == false
    end
  end

  describe "equalify" do
    test "returns false when elements are the same, but nested values are not in the same order" do
      assert Morphix.equalify?([1, 2, [3, 4, 5]], [1, 2, [3, 5, 4]]) == false

      assert Morphix.equalify?(%{a: [1, 2, 3], b: [1, 2, 3]}, %{a: [1, 2, 3], b: [3, 2, 1]}) ==
               false

      assert Morphix.equalify?(
               {123, :ok, true, %{a: [4, 5, 6]}},
               {true, :ok, 123, %{a: [5, 4, 6]}}
             ) == false
    end

    test "returns true when elements are the same, regardless of order" do
      assert Morphix.equalify?([1, :three, "two", %{a: [4, 5, 6]}], [
               1,
               "two",
               %{a: [4, 5, 6]},
               :three
             ]) == true

      assert Morphix.equalify?(%{a: 1, c: :three, b: "two"}, %{b: "two", c: :three, a: 1}) == true

      assert Morphix.equalify?({:ok, true, 123}, {true, :ok, 123}) == true
      assert Morphix.equalify?(123, 123) == true
    end
  end

  describe "#strigmorphiphorm" do
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

      assert Morphix.stringomorphiform!(test_map, [:this, :that, :the, :how, :heck]) ==
               expected_map
    end
  end

  test "stringmorphify! will throw appropriate exceptions" do
    map = %{example: "atoms"}

    assert_raise ArgumentError, "expecting a list of atoms, got: 1", fn ->
      Morphix.stringmorphify!(map, 1)
    end
  end
end
