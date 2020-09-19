defmodule Morphix do
  @moduledoc """
  Morphix provides convenience methods for dealing with Maps, Lists, and Tuples.

  `morphiflat/1` and `morphiflat!/1` flatten maps, discarding top level keys.
  ### Examples:

  ```
  iex> Morphix.morphiflat %{flatten: %{this: "map"}, if: "you please"}
  {:ok, %{this: "map", if: "you please"}}

  iex> Morphix.morphiflat! %{flatten: %{this: "map"}, o: "k"}
  %{this: "map", o: "k"}

  ```

  `morphify!/2` and `morphify/2` will take either a List or a Tuple as the first argument, and a function as the second. Returns a map, with the keys of the map being the function applied to each member of the input.

  ### Examples:

  ```
  iex> Morphix.morphify!({[1,2,3], [12], [1,2,3,4]}, &length/1)
  %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}

  ```

  `atomorphify/1` and `atomorphiform/1` take a map as an input and return the map with all string keys converted to atoms. `atomorphiform/1` is recursive. `atomorphiform/2` and `atomormiphify/2` take `:safe` as a second argument, they will not convert string keys if the resulting atom has not been defined.

  ### Examples:

  ```
  iex> Morphix.atomorphify(%{"a" => "2", :a => 2, 'a'  => :two})
  {:ok, %{:a => 2, 'a' => :two }}

  ```

  `compactify` and `compactiform` take a map or list as an input and returns a filtered map or list, removing any keys or elements with nil values or with an empty map as a value.

  `partiphify!/2` and `partiphify/2` take a list `l` and an integer `k` and partition `l` into `k` sublists of balanced size. There will always be `k` lists, even if some must be empty.

  ### Examples:

  ```
  iex> Morphix.partiphify!([:a, :b, :c, :d, :e, :f], 4)
  [[:c], [:d], [:e, :a], [:f, :b]]

  iex> Morphix.partiphify!([:a, :b, :c, :d, :e], 4)
  [[:b], [:c], [:d], [:e, :a]]

  iex> Morphix.partiphify!([:a, :b, :c, :d], 4)
  [[:a], [:b], [:c], [:d]]

  iex> Morphix.partiphify!([:a, :b, :c], 4)
  [[:a], [:b], [:c], []]

  ```

  `equaliform?/2` compares two ordered or unordered lists and returns `true` if they are equal. It also handles nested elements.

  ### Example:
      iex> Morphix.equaliform?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [[:three, "two"], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      true

  `equalify?/2` compares two ordered or unordered lists and returns `true` if they are equal.

  ### Example:
      iex> Morphix.equalify?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [["two", :three], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      true

  """

  use Util.EqualityOperator

  @spec morphiflat(map()) :: {:ok | :error, map() | String}
  @spec morphiflat!(map()) :: map()
  @spec morphify([any], fun()) :: {:ok | :error, map() | String.t()}
  @spec morphify(tuple(), fun()) :: {:ok | :error, map() | String.t()}
  @spec morphify!([any], fun()) :: map()
  @spec morphify!(tuple(), fun()) :: map()
  @spec atomorphify(map()) :: {:ok, map()}
  @spec atomorphify(map(), :safe) :: {:ok, map()}
  @spec atomorphify(map(), list()) :: {:ok, map()}
  @spec atomorphify!(map()) :: map()
  @spec stringmorphify!(map()) :: map()
  @spec stringmorphify!(map(), list()) :: map()
  @spec atomorphify!(map(), :safe) :: map()
  @spec atomorphify!(map(), list()) :: map()
  @spec morphiform!(map(), fun(), list()) :: map()
  @spec atomorphiform(map()) :: {:ok, map()}
  @spec atomorphiform(map(), :safe) :: {:ok, map()}
  @spec atomorphiform(map(), list()) :: {:ok, map()}
  @spec atomorphiform!(map()) :: map()
  @spec atomorphiform!(map(), :safe) :: map()
  @spec atomorphiform!(map(), list()) :: map()
  @spec stringmorphiform!(map) :: map()
  @spec stringmorphiform!(map, list()) :: map()
  @spec compactify(map() | list()) :: {:ok, map()} | {:ok, list()} | {:error, %ArgumentError{}}
  @spec compactify!(map() | list()) :: map() | list() | %ArgumentError{}
  @spec compactiform!(map() | list()) :: map() | list() | %ArgumentError{}
  @spec compactiform(map() | list()) :: {:ok, map()} | {:ok, list()} | {:error, %ArgumentError{}}
  @spec partiphify!(list(), integer) :: [list[any]] | no_return
  @spec partiphify(list(), integer) :: {:ok, [list[any]]} | {:error, term}

  @doc """
  Takes a map and returns a flattend version of that map, discarding any nested keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat! %{you: "will", youwill: %{be: "discarded"}}
  %{you: "will", be: "discarded"}

  ```
  """
  def morphiflat!(map) do
    flattn(map)
  end

  @doc """
  Takes a map and returns a flattened version of that map. If the map has nested maps (or the maps nested maps have nested maps, etc.) morphiflat moves all nested key/value pairs to the top level, discarding the original keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat %{this: %{nested: :map, inner: %{twonested: :map, is: "now flat"}}}
  {:ok, %{nested: :map, twonested: :map, is: "now flat"}}

  ```

  In the example, the key `:this` is discarded, along with the key `inner`, because they both point to map values.

  Will return `{:error, <input> is not a Map}` if the input is not a map.

  ### Examples:
  ```
  iex> Morphix.morphiflat({1,2,3})
  {:error, "{1, 2, 3} is not a Map"}

  ```
  """
  def morphiflat(map) when is_map(map) do
    {:ok, flattn(map)}
  rescue
    exception -> {:error, Exception.message(exception)}
  end

  def morphiflat(not_map), do: {:error, "#{inspect(not_map)} is not a Map"}

  defp flattn(map) do
    not_maps = fn {k, v}, acc ->
      case is_map(v) do
        false -> Map.put_new(acc, k, v)
        true -> Map.merge(acc, flattn(v))
      end
    end

    Enum.reduce(map, %{}, not_maps)
  end

  @doc """

  Takes a map as an argument and returns `{:ok, map}`, with string keys converted to atom keys. Does not examine nested maps.

  ### Examples

  ```
  iex> Morphix.atomorphify(%{"this" => "map", "has" => %{"string" => "keys"}})
  {:ok, %{this: "map", has: %{"string" => "keys"}}}

  iex> Morphix.atomorphify(%{1 => "2", "1" => 2, "one" => :two})
  {:ok, %{1 => "2", "1": 2, one: :two}}

  ```
  """
  def atomorphify(map) when is_map(map) do
    {:ok, atomorphify!(map)}
  rescue
    e -> {:error, e}
  end

  @doc """
  Takes a map and the `:safe` flag and returns `{:ok, map}`, with string keys converted to existing atoms if possible, and ignored otherwise. Ignores nested maps.

  ### Examples:

  ```
  iex> :existing_atom
  iex> Morphix.atomorphify(%{"existing_atom" => "exists", "non_existent_atom" => "does_not", 1 => "is_ignored"}, :safe)
  {:ok, %{ "non_existent_atom" => "does_not", 1 => "is_ignored", existing_atom: "exists"}}

  ```
  """
  def atomorphify(map, :safe) when is_map(map) do
    {:ok, atomorphify!(map, :safe)}
  rescue
    e -> {:error, e}
  end

  @doc """
  Takes a map and a list of allowed strings to convert to atoms and returns `{:ok, map}`, with string keys in the list converted to atoms. Ignores nested maps.

  ### Examples:

  ```
  iex> Morphix.atomorphify(%{"allowed_key" => "exists", "non_existent_atom" => "does_not", 1 => "is_ignored"}, ["allowed_key"])
  {:ok, %{ "non_existent_atom" => "does_not", 1 => "is_ignored", allowed_key: "exists"}}

  ```
  """
  def atomorphify(map, allowed) when is_map(map) and is_list(allowed) do
    {:ok, atomorphify!(map, allowed)}
  rescue
    e -> {:error, e}
  end

  @doc """

  Takes a map as an argument and returns the same map with string keys converted to atom keys. Does not examine nested maps.

  ### Examples

  ```
  iex> Morphix.atomorphify!(%{"this" => "map", "has" => %{"string" => "keys"}})
  %{this: "map", has: %{"string" => "keys"}}

  iex> Morphix.atomorphify!(%{1 => "2", "1" => 2, "one" => :two})
  %{1 => "2", "1": 2, one: :two}

  ```
  """
  def atomorphify!(map) when is_map(map) do
    keymorphify!(map, &atomize_binary/2)
  end

  @doc """
  Takes a map and the `:safe` flag and returns the same map, with string keys converted to existing atoms if possible, and ignored otherwise. Ignores nested maps.

  ### Examples:

  ```
  iex> :existing_atom
  iex> Morphix.atomorphify!(%{"existing_atom" => "exists", "non_existent_atom" => "does_not", 1 => "is_ignored"}, :safe)
  %{"non_existent_atom" => "does_not", 1 => "is_ignored", existing_atom: "exists"}

  ```
  """
  def atomorphify!(map, :safe) when is_map(map) do
    keymorphify!(map, &safe_atomize_binary/2)
  end

  @doc """
  Takes a map and a list of allowed strings to convert to atoms and returns the same map, with string keys in the list converted to atoms. Ignores nested maps.

  ### Examples:

  ```
  iex> Morphix.atomorphify!(%{"allowed_key" => "exists", "non_existent_atom" => "does_not", 1 => "is_ignored"}, ["allowed_key"])
  %{"non_existent_atom" => "does_not", 1 => "is_ignored", allowed_key: "exists"}

  ```
  """
  def atomorphify!(map, []) when is_map(map), do: map

  def atomorphify!(map, allowed) when is_map(map) and is_list(allowed) do
    keymorphify!(map, &safe_atomize_binary/2, allowed)
  end

  @doc """

  Takes a map as an argument and returns the same map with atom keys converted to string keys. Does not examine nested maps.

  ### Examples

  ```
  iex> Morphix.stringmorphify!(%{this: "map", has: %{"string" => "keys"} })
  %{"this" => "map", "has" => %{"string" => "keys"}}

  iex> Morphix.stringmorphify!(%{1 => "2", "1" => 2, one: :two})
  %{1 => "2", "1" => 2, "one" => :two}

  ```
  """
  def stringmorphify!(map) when is_map(map) do
    keymorphify!(map, &binarize_atom/2)
  end

  @doc """
  Takes a map and a list of allowed atoms as arguments and returns the same map, with any atoms that are in the list converted to strings, and any atoms that are not in the list left as atoms.


  ### Examples:

  ```
  iex> map = %{memberof: "atoms", embeded: %{"wont" => "convert"}}
  iex> Morphix.stringmorphify!(map, [:memberof])
  %{:embeded => %{"wont" => "convert"}, "memberof" => "atoms"}

  ```

  ```
  iex> map = %{id: "fooobarrr", date_of_birth: ~D[2014-04-14]}
  iex> Morphix.stringmorphify!(map)
  %{"id" => "fooobarrr", "date_of_birth" => ~D[2014-04-14]}
  ```

  """
  def stringmorphify!(map, []) when is_map(map), do: map

  def stringmorphify!(map, allowed) when is_map(map) and is_list(allowed) do
    keymorphify!(map, &binarize_atom/2, allowed)
  end

  def stringmorphify!(map, not_allowed) when is_map(map) do
    raise(ArgumentError, message: "expecting a list of atoms, got: #{inspect(not_allowed)}")
  end

  def stringmorphify!(not_map, _) when not is_map(not_map) do
    raise(ArgumentError, message: "expecting a map, got: #{inspect(not_map)}")
  end

  @doc """
  Takes a map as an argument and returns `{:ok, map}`, with all string keys (including keys in nested maps) converted to atom keys.

  ### Examples:

  ```
  iex> Morphix.atomorphiform(%{:this => %{map: %{"has" => "a", :nested => "string", :for =>  %{a: :key}}}, "the" =>  %{"other" => %{map: :does}}, as: "well"})
  {:ok,%{this: %{map: %{has: "a", nested: "string", for: %{a: :key}}}, the: %{other: %{map: :does}}, as: "well"} }

  iex> Morphix.atomorphiform(%{"this" => ["map", %{"has" => ["a", "list"]}], "inside" => "it"})
  {:ok, %{this: ["map", %{has: ["a", "list"]}], inside: "it"}}

  ```
  """
  def atomorphiform(map) when is_map(map) do
    {:ok, atomorphiform!(map)}
  end

  @doc """
  Takes a map and the `:safe` flag as arguments and returns `{:ok, map}`, with any strings that are existing atoms converted to atoms, and any strings that are not existing atoms left as strings.

  Works recursively on embedded maps.

  ### Examples:

  ```
  iex> [:allowed, :values]
  iex> map = %{"allowed" => "atoms", "embed" => %{"will" => "convert", "values" => "to atoms"}}
  iex> Morphix.atomorphiform(map, :safe)
  {:ok, %{"embed" => %{"will" => "convert", values: "to atoms"}, allowed: "atoms"}}

  ```
  """
  def atomorphiform(map, :safe) when is_map(map) do
    {:ok, atomorphiform!(map, :safe)}
  end

  @doc """
  Takes a map and a list of allowed strings as arguments and returns `{:ok, map}`, with any strings that are in the list converted to atoms, and any strings that are not in the list left as strings.

  Works recursively on embedded maps.

  ### Examples:

  ```
  iex> map = %{"memberof" => "atoms", "embed" => %{"will" => "convert", "thelist" => "to atoms"}}
  iex> Morphix.atomorphiform(map, ["memberof", "thelist"])
  {:ok, %{"embed" => %{"will" => "convert", thelist: "to atoms"}, memberof: "atoms"}}

  ```
  """
  def atomorphiform(map, allowed) when is_map(map) and is_list(allowed) do
    {:ok, atomorphiform!(map, allowed)}
  rescue
    e -> {:error, e}
  end

  @doc """
  Takes a map as an argument and returns the same map, with all string keys (including keys in nested maps) converted to atom keys.

  ### Examples:

  ```
  iex> Morphix.atomorphiform!(%{:this => %{map: %{"has" => "a", :nested => "string", :for =>  %{a: :key}}}, "the" =>  %{"other" => %{map: :does}}, as: "well"})
  %{this: %{map: %{has: "a", nested: "string", for: %{a: :key}}}, the: %{other: %{map: :does}}, as: "well"}

  iex> Morphix.atomorphiform!(%{"this" => ["map", %{"has" => ["a", "list"]}], "inside" => "it"})
  %{this: ["map", %{has: ["a", "list"]}], inside: "it"}

  ```
  """
  def atomorphiform!(map) when is_map(map) do
    morphiform!(map, &atomize_binary/2)
  end

  @doc """
  Takes a map and the `:safe` flag as arguments and returns the same map, with any strings that are existing atoms converted to atoms, and any strings that are not existing atoms left as strings.

  Works recursively on embedded maps.

  ### Examples:

  ```
  iex> [:allowed, :values]
  iex> map = %{"allowed" => "atoms", "embed" => %{"will" => "convert", "values" => "to atoms"}}
  iex> Morphix.atomorphiform!(map, :safe)
  %{"embed" => %{"will" => "convert", values: "to atoms"}, allowed: "atoms"}

  ```
  """
  def atomorphiform!(map, :safe) when is_map(map) do
    morphiform!(map, &safe_atomize_binary/2)
  end

  @doc """
  Takes a map and a list of allowed strings as arguments and returns the same map, with any strings that are in the list converted to atoms, and any strings that are not in the list left as strings.

  Works recursively on embedded maps.

  ### Examples:

  ```
  iex> map = %{"memberof" => "atoms", "embed" => %{"will" => "convert", "thelist" => "to atoms"}}
  iex> Morphix.atomorphiform!(map, ["memberof", "thelist"])
  %{"embed" => %{"will" => "convert", thelist: "to atoms"}, memberof: "atoms"}

  ```

  ```
  iex> map = %{"id" => "fooobarrr", "date_of_birth" => ~D[2014-04-14]}
  %{"date_of_birth" => ~D[2014-04-14], "id" => "fooobarrr"}
  iex> Morphix.atomorphiform!(map)
  %{id: "fooobarrr", date_of_birth: ~D[2014-04-14]}
  ```

  """
  def atomorphiform!(map, []) when is_map(map), do: map

  def atomorphiform!(map, allowed) when is_map(map) and is_list(allowed) do
    morphiform!(map, &safe_atomize_binary/2, allowed)
  end

  def stringmorphiform!(map) when is_map(map) do
    morphiform!(map, &stringify_all/2)
  end

  def stringmorphiform!(map, []) when is_map(map), do: map

  def stringmorphiform!(map, allowed) when is_map(map) and is_list(allowed) do
    morphiform!(map, &stringify_all/2, allowed)
  end

  def stringmorphiform!(map, not_allowed) when is_map(map) do
    raise(ArgumentError, message: "expecting a list of atoms, got: #{inspect(not_allowed)}")
  end

  def stringmorphiform!(not_map, _) when not is_map(not_map) do
    raise(ArgumentError, message: "expecting a map, got: #{inspect(not_map)}")
  end

  defp stringify_all(value, []) do
    if is_atom(value) do
      try do
        to_string(value)
      rescue
        _ -> value
      end
    else
      value
    end
  end

  defp stringify_all(value, allowed) do
    if is_atom(value) && Enum.member?(allowed, value) do
      to_string(value)
    else
      value
    end
  end

  defp process_list_item(item, transformer, allowed) do
    cond do
      is_map(item) -> morphiform!(item, transformer, allowed)
      is_list(item) -> Enum.map(item, fn x -> process_list_item(x, transformer, allowed) end)
      true -> item
    end
  end

  @doc """
  Takes a map and a function as an argument and returns the same map, with all keys transformed by the function.(including keys in nested maps) converted to atom keys.

  The function passed in must take two arguments, the key, and an allowed list.

  ### Examples:

  ```
  iex> Morphix.morphiform!(%{"this" => %{"map" => %{"has" => "a", "nested" => "string", "for" =>  %{"a" => :key}}}, "the" =>  %{"other" => %{"map" => :does}},"as" => "well"}, fn key, [] -> String.upcase(key) end)
  %{"THIS" => %{"MAP" => %{"HAS" => "a", "NESTED" => "string", "FOR" => %{"A" => :key}}}, "THE" => %{"OTHER" => %{"MAP" => :does}}, "AS" => "well"}

  ```

  """
  def morphiform!(map, transformer, allowed \\ []) when is_map(map) do
    morphkeys = fn {k, v}, acc ->
      cond do
        is_struct(v) ->
          Map.put_new(acc, transformer.(k, allowed), v)

        is_map(v) ->
          Map.put_new(
            acc,
            transformer.(k, allowed),
            morphiform!(v, transformer, allowed)
          )

        is_list(v) ->
          Map.put_new(
            acc,
            transformer.(k, allowed),
            process_list_item(v, transformer, allowed)
          )

        true ->
          Map.put_new(acc, transformer.(k, allowed), v)
      end
    end

    Enum.reduce(map, %{}, morphkeys)
  end

  defp keymorphify!(map, transformer, allowed \\ []) do
    morphkeys = fn {k, v}, acc ->
      Map.put_new(acc, transformer.(k, allowed), v)
    end

    Enum.reduce(map, %{}, morphkeys)
  end

  defp atomize_binary(value, []) do
    if is_binary(value) && String.printable?(value) do
      String.to_atom(value)
    else
      value
    end
  end

  defp binarize_atom(value, []) do
    if is_atom(value) do
      Atom.to_string(value)
    else
      value
    end
  end

  defp binarize_atom(value, allowed) do
    if is_atom(value) && Enum.member?(allowed, value) do
      Atom.to_string(value)
    else
      value
    end
  end

  defp safe_atomize_binary(value, []) do
    if is_binary(value) do
      try do
        String.to_existing_atom(value)
      rescue
        _ -> value
      end
    else
      value
    end
  end

  defp safe_atomize_binary(value, allowed) do
    if !Enum.all?(allowed, fn x -> is_binary(x) && String.printable?(x) end) do
      raise %ArgumentError{message: "#{inspect(allowed)} contains members that are not Strings."}
    end

    if is_binary(value) && Enum.member?(allowed, value) do
      String.to_atom(value)
    else
      value
    end
  end

  @doc """
  Takes a List and a function as arguments and returns `{:ok, Map}`, with the keys of the map the result of applying the function to each item in the list.

  If the function cannot be applied, will return `{:error, message}`

  ### Examples
  ```
  iex> Morphix.morphify([[1,2,3], [12], [1,2,3,4]], &Enum.count/1)
  {:ok, %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}}

  iex> Morphix.morphify({[1,2,3], [12], [1,2,3,4]}, &length/1)
  {:ok, %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}}

  iex> Morphix.morphify([1,2], &String.length/1)
  {:error, "Unable to apply &String.length/1 to each of [1, 2]"}

  ```
  """
  def morphify(enum, funct) when is_tuple(enum), do: morphify(Tuple.to_list(enum), funct)

  def morphify(enum, funct) do
    {:ok, morphify!(enum, funct)}
  rescue
    _ -> {:error, "Unable to apply #{inspect(funct)} to each of #{inspect(enum)}"}
  end

  @doc """
  Takes a list and a function as arguments and returns a Map, with the keys of the map the result of applying the function to each item in the list.

  ### Examples
  ```
  iex> Morphix.morphify!([[1,2,3], [12], [1,2,3,4]], &Enum.count/1)
  %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}

  ```
  """
  def morphify!(enum, funct) when is_tuple(enum), do: morphify!(Tuple.to_list(enum), funct)

  def morphify!(enum, funct) do
    Enum.reduce(enum, %{}, fn x, acc -> Map.put(acc, funct.(x), x) end)
  end

  @doc """
  Takes a map or list and removes keys or elements that have nil values, or are empty maps.

  ### Examples
  ```
  iex> Morphix.compactify!(%{nil_key: nil, not_nil: "nil"})
  %{not_nil: "nil"}

  iex> Morphix.compactify!([1, nil, "string", %{key: :value}])
  [1, "string", %{key: :value}]

  iex> Morphix.compactify!([a: nil, b: 2, c: "string"])
  [b: 2, c: "string"]

  iex> Morphix.compactify!(%{empty: %{}, not: "not"})
  %{not: "not"}

  iex> Morphix.compactify!({"not", "a map"})
  ** (ArgumentError) expecting a map or a list, got: {"not", "a map"}

  ```
  """

  def compactify!(map) when is_map(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) || empty_map(v) end)
    |> Enum.into(%{})
  end

  def compactify!(list) when is_list(list) do
    list
    |> Keyword.keyword?()
    |> compactify!(list)
  end

  def compactify!(not_map_or_list) do
    raise(ArgumentError, message: "expecting a map or a list, got: #{inspect(not_map_or_list)}")
  end

  defp compactify!(true, list) do
    Enum.reject(list, fn {_k, v} -> is_nil(v) end)
  end

  defp compactify!(false, list) do
    Enum.reject(list, fn elem -> is_nil(elem) end)
  end

  @doc """
  Takes a map or a list and removes any keys or elements that have nil values.

  ### Examples
  ```
  iex> Morphix.compactify(%{nil_key: nil, not_nil: "real value"})
  {:ok, %{not_nil: "real value"}}

  iex> Morphix.compactify([1, nil, "string", %{key: :value}])
  {:ok, [1, "string", %{key: :value}]}

  iex> Morphix.compactify([a: nil, b: 2, c: "string"])
  {:ok, [b: 2, c: "string"]}

  iex> Morphix.compactify(%{empty: %{}, not: "not"})
  {:ok, %{not: "not"}}

  iex> Morphix.compactify("won't work")
  {:error, %ArgumentError{message: "expecting a map or a list, got: \\"won't work\\""}}

  ```
  """

  def compactify(map_or_list) do
    {:ok, compactify!(map_or_list)}
  rescue
    e -> {:error, e}
  end

  @doc """
  Removes keys with nil values from nested maps, eliminates empty maps, and removes nil values from nested lists.

  ### Examples
  ```
  iex> Morphix.compactiform!(%{nil_nil: nil, not_nil: "a value", nested: %{nil_val: nil, other: "other"}})
  %{not_nil: "a value", nested: %{other: "other"}}

  iex> Morphix.compactiform!(%{nil_nil: nil, not_nil: "a value", nested: %{nil_val: nil, other: "other", nested_empty: %{}}})
  %{not_nil: "a value", nested: %{other: "other"}}

  iex> Morphix.compactiform!([nil, "string", %{nil_nil: nil, not_nil: "a value", nested: %{nil_val: nil, other: "other", nested_empty: %{}}}, ["nested", nil, 2]])
  ["string", %{not_nil: "a value", nested: %{other: "other"}}, ["nested", 2]]

  ```
  """

  def compactiform!(map) when is_map(map) do
    compactor = fn {k, v}, acc ->
      cond do
        is_struct(v) -> Map.put_new(acc, k, v)
        is_map(v) and Enum.empty?(v) -> acc
        is_map(v) or is_list(v) -> Map.put_new(acc, k, compactiform!(v))
        is_nil(v) -> acc
        true -> Map.put_new(acc, k, v)
      end
    end

    map
    |> Enum.reduce(%{}, compactor)
    |> compactify!
  end

  def compactiform!(list) when is_list(list) do
    compactor = fn elem, acc ->
      cond do
        is_list(elem) and Enum.empty?(elem) -> acc
        is_list(elem) or is_map(elem) -> acc ++ [compactiform!(elem)]
        is_nil(elem) -> acc
        true -> acc ++ [elem]
      end
    end

    list
    |> Enum.reduce([], compactor)
    |> compactify!
  end

  def compactiform!(not_map_or_list) do
    raise(ArgumentError, message: "expecting a map or a list, got: #{inspect(not_map_or_list)}")
  end

  @doc """
  Removes keys with nil values from maps and nil elements from lists. It also handles nested maps and lists, and treats empty maps as nil values.

  ### Examples
  ```
  iex> Morphix.compactiform(%{a: nil, b: "not", c: %{d: nil, e: %{}, f: %{g: "value"}}})
  {:ok, %{b: "not", c: %{f: %{g: "value"}}}}

  iex> Morphix.compactiform(%{has: %{a: ["list", "with", nil]}, and: ["a", %{nested: "map", with: nil}]})
  {:ok, %{has: %{a: ["list", "with"]}, and: ["a", %{nested: "map"}]}}

  iex> Morphix.compactiform(["list", %{a: "map", with: nil, and_empty: []}])
  {:ok, ["list", %{a: "map", and_empty: []}]}

  iex> Morphix.compactiform(5)
  {:error, %ArgumentError{message: "expecting a map or a list, got: 5"}}

  ```
  """
  def compactiform(map) do
    {:ok, compactiform!(map)}
  rescue
    e -> {:error, e}
  end

  @doc """
  Divides a list into k distinct sub-lists, with partitions being as close to the same size as possible

  ### Examples
  ```
  iex> Morphix.partiphify!([1,2,3,4,5,6], 4)
  [[3], [4], [5, 1], [6, 2]]

  iex> Morphix.partiphify!(("abcdefghijklmnop" |> String.split("", trim: true)), 4)
  [["a", "b", "c", "d"], ["e", "f", "g", "h"], ["i", "j", "k", "l"], ["m", "n", "o", "p"]]

  ```
  """
  def partiphify!(list, k) when is_list(list) and is_integer(k) do
    ceil_div = fn a, b -> Float.ceil(a / b) end

    with chunk_size when chunk_size > 0 <-
           list
           |> Enum.count()
           |> Integer.floor_div(k),
         true <-
           list
           |> Enum.count()
           |> Integer.mod(k)
           |> ceil_div.(chunk_size) > 0 do
      list
      |> into_buckets(k, chunk_size)
      |> distribute_extra()
    else
      0 ->
        list = Enum.chunk_every(list, 1, 1, [])
        empty_buckets = k - Enum.count(list)
        Enum.reduce(1..empty_buckets, list, fn _, acc -> acc ++ [[]] end)

      false ->
        chunk_size =
          list
          |> Enum.count()
          |> Integer.floor_div(k)

        Enum.chunk_every(list, chunk_size, chunk_size, [])
    end
  end

  defp into_buckets(list, k, chunk_size) do
    chunks = Enum.chunk_every(list, chunk_size, chunk_size, [])
    extra_buckets = Enum.take(chunks, -(Enum.count(chunks) - k))
    k_buckets = chunks -- extra_buckets
    {extra_buckets, k_buckets}
  end

  @doc """
  Divides a list into k distinct sub-lists, with partitions being as close to the same size as possible

  ### Examples
  ```
  iex> Morphix.partiphify([1,2,3,4,5,6], 4)
  {:ok, [[3], [4], [5, 1], [6, 2]]}

  iex> Morphix.partiphify(("abcdefghijklmnop" |> String.split("", trim: true)), 4)
  {:ok, [["a", "b", "c", "d"], ["e", "f", "g", "h"], ["i", "j", "k", "l"], ["m", "n", "o", "p"]]}
  ```
  """
  def partiphify(list, k) do
    {:ok, partiphify!(list, k)}
  rescue
    e -> {:error, e}
  end

  defp distribute(list, buckets) do
    Enum.reduce(list, buckets, fn item, buckets ->
      [current_bucket | rest_of_buckets] = buckets
      new_bucket = [item | current_bucket]
      rest_of_buckets ++ [new_bucket]
    end)
  end

  defp distribute_extra({lists, buckets}) do
    with false <- Enum.empty?(lists) do
      [current_list | rest] = lists
      new_buckets = distribute(current_list, buckets)
      distribute_extra({rest, new_buckets})
    else
      _ -> buckets
    end
  end

  defp empty_map(map) do
    is_map(map) && not Map.has_key?(map, :__struct__) && Enum.empty?(map)
  end

  if !macro_exported?(Kernel, :is_struct, 1) do
    defp is_struct(s), do: is_map(s) and Map.has_key?(s, :__struct__)
  end
end
