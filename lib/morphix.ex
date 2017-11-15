defmodule Morphix do
  @moduledoc """
  Morphix provides convenience methods for dealing with Maps, Lists, and Tuples.

  `morphiflat` and `morphiflat!` flatten maps, discarding top level keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat %{flatten: %{this: "map"}, if: "you please"}
  {:ok, %{this: "map", if: "you please"}}

  iex> Morphix.morphiflat! %{flatten: %{this: "map"}, o: "k"}
  %{this: "map", o: "k"}

  ```

  `morphify!` and `morphify` will take either a List or a Tuple as the first argument, and a function as the second. Returns a map, with the keys of the map being the function applied to each member of the input.

  ### Examples:

  ```
  iex> Morphix.morphify!({[1,2,3], [12], [1,2,3,4]}, &length/1)
  %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}

  ```

  `atomorphify` and `atomorphiform` take a map as an input and return the map with all string keys converted to atoms. `atomorphiform` is recursive.
  ### Examples:

  ```
  iex> Morphix.atomorphify(%{"a" => "2", :a => 2, 'a'  => :two})
  {:ok, %{:a => 2, 'a' => :two }}

  ```

  `compactify` and `compactiform` take a map as an input and return a filtered map, removing any keys with nil values or with an empty map as a value.
  """

  @spec morphiflat(Map.t) :: {:ok | :error, Map.t | String}
  @spec morphiflat!(Map.t) :: Map.t
  @spec morphify(List.t, Function) :: {:ok|:error, Map.t | String}
  @spec morphify(Tuple.t, Function) :: {:ok|:error, Map.t | String}
  @spec morphify!(List.t, Function) :: Map.t
  @spec morphify!(Tuple.t, Function) :: Map.t
  @spec atomorphify(Map.t, :safe) :: {:ok, Map.t}
  @spec atomorphify(Map.t) :: {:ok, Map.t}
  @spec atomorphiform(Map.t, :safe) :: {:ok, Map.t}
  @spec atomorphiform(Map.t) :: {:ok, Map.t}
  @spec compactify(Map.t) :: {:ok, Map.t}
  @spec compactify!(Map.t) :: Map.t
  @spec compactiform!(Map.t) :: Map.t
  @spec compactiform(Map.t) :: {:ok, Map.t}
  @spec partiphify!(List.t, Integer) :: List.t

  @doc """
  Takes a map and returns a flattend version of that map, discarding any nested keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat! %{you: "will", youwill: %{be: "discarded"}}
  %{you: "will", be: "discarded"}

  ```
  """
  def morphiflat! map do
    flattn map
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
  def morphiflat(map) when is_map map do
    {:ok, flattn map}
  rescue
    exception -> {:error, Exception.message(exception)}
  end
  def morphiflat(not_map), do: {:error, "#{inspect(not_map)} is not a Map"}

  defp flattn map do
    not_maps = fn({k, v}, acc) ->
      case is_map v do
        false -> Map.put_new(acc, k, v)
        true -> Map.merge(acc, flattn(v))
      end
    end
    Enum.reduce(map, %{}, not_maps)
  end

  @doc """

  Takes a map as an argument and returns the same map with string keys converted to atom keys. Does not examine nested maps.

  ### Examples

  ```
  iex> Morphix.atomorphify(%{"this" => "map", "has" => %{"string" => "keys"}})
  {:ok, %{this: "map", has: %{"string" => "keys"}}}

  iex> Morphix.atomorphify(%{1 => "2", "1" => 2, "one" => :two})
  {:ok, %{1 => "2", "1": 2, one: :two}}

  ```
  """
  def atomorphify(map) when is_map map do
    {:ok, atomog(map, &atomize_binary/1)}
  end

  @doc """
  Takes a map and the `:safe` flag, returns the same map, with string keys converted to existing atoms if possible, and ignored otherwise. Ignores nested maps.

  ### Examples:

  ```
  iex> :existing_atom
  iex> Morphix.atomorphify(%{"existing_atom" => "exists", "non_existent_atom" => "does_not", 1 => "is_ignored"}, :safe)
  {:ok, %{ "non_existent_atom" => "does_not", 1 => "is_ignored", existing_atom: "exists"}}

  ```
  """
  def atomorphify(map, :safe) when is_map map do
    {:ok, (atomog map, &safe_atomize_binary/1)}
  end

  @doc """
  Takes a map as an argument and returns the same map, with all string keys (including keys in nested maps) converted to atom keys.

  ### Examples:

  ```
  iex> Morphix.atomorphiform(%{:this => %{map: %{"has" => "a", :nested => "string", :for =>  %{a: :key}}}, "the" =>  %{"other" => %{map: :does}}, as: "well"})
  {:ok,%{this: %{map: %{has: "a", nested: "string", for: %{a: :key}}}, the: %{other: %{map: :does}}, as: "well"} }

  iex> Morphix.atomorphiform(%{"this" => ["map", %{"has" => ["a", "list"]}], "inside" => "it"})
  {:ok, %{this: ["map", %{has: ["a", "list"]}], inside: "it"}}

  ```
  """
  def atomorphiform(map) when is_map map do
    {:ok, depth_atomog(map, &atomize_binary/1)}
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
  def atomorphiform(map, :safe) when is_map map do
    {:ok, depth_atomog(map, &safe_atomize_binary/1)}
  end

  defp process_list_item(item, safe_or_atomize) do
    cond do
      is_map item -> depth_atomog(item, safe_or_atomize)
      is_list item -> Enum.map(item, fn(x) -> process_list_item(x, safe_or_atomize) end)
      true -> item
    end
  end

  defp depth_atomog(map, safe_or_atomize) do
    atomkeys = fn({k, v}, acc) ->
      cond do
        is_map v ->
          Map.put_new(acc, safe_or_atomize.(k), depth_atomog(v, safe_or_atomize))
        is_list v ->
          Map.put_new(acc, safe_or_atomize.(k), process_list_item(v, safe_or_atomize))
        true ->
          Map.put_new(acc, safe_or_atomize.(k), v)
      end
    end
    Enum.reduce(map, %{}, atomkeys)
  end

  defp atomog(map, safe_or_atomize) do
    atomkeys = fn({k, v}, acc) ->
      Map.put_new(acc, safe_or_atomize.(k), v)
    end
    Enum.reduce(map, %{}, atomkeys)
  end

  defp atomize_binary(value) do
    if is_binary(value) do
      String.to_atom(value)
    else
      value
    end
  end

  defp safe_atomize_binary(value) do
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
    Enum.reduce(enum,
    %{},
    fn(x, acc) -> Map.put(acc, funct.(x), x) end)
  end

  @doc """
  Takes a map and removes keys that have nil values, or are empty maps.

  ### Examples
  ```
  iex> Morphix.compactify!(%{nil_key: nil, not_nil: "nil"})
  %{not_nil: "nil"}

  iex> Morphix.compactify!(%{empty: %{}, not: "not"})
  %{not: "not"}

  ```
  """

  def compactify!(map) when is_map(map) do
    map
    |> Enum.reject(fn({_k, v}) -> is_nil(v) || empty_map(v) end)
    |> Enum.into(%{})
  end

  @doc """
  Takes a map and removes any keys that have nil values.

  ### Examples
  ```
  iex> Morphix.compactify(%{nil_key: nil, not_nil: "real value"})
  {:ok, %{not_nil: "real value"}}

  iex> Morphix.compactify("won't work")
  {:error, %FunctionClauseError{arity: 1, function: :compactify!, module: Morphix}}

  ```
  """

  def compactify(map) do
    {:ok, compactify!(map)}
  rescue
    e -> {:error, e}
  end

  @doc """
  Removes keys with nil values from nested maps, also eliminates empty maps.

  ### Examples
  ```
  iex> Morphix.compactiform!(%{nil_nil: nil, not_nil: "a value", nested: %{nil_val: nil, other: "other"}})
  %{not_nil: "a value", nested: %{other: "other"}}

  iex> Morphix.compactiform!(%{nil_nil: nil, not_nil: "a value", nested: %{nil_val: nil, other: "other", nested_empty: %{}}})
  %{not_nil: "a value", nested: %{other: "other"}}

  ```
  """

  def compactiform!(map) when is_map(map) do
    compactor = fn({k, v}, acc) ->
      cond do
        is_struct(v) -> Map.put_new(acc, k, v)
        is_map(v) and Enum.empty?(v) -> acc
        is_map(v) -> Map.put_new(acc, k, compactiform!(v))
        is_nil(v) -> acc
        true -> Map.put_new(acc, k, v)
      end
    end
    map
    |> Enum.reduce(%{}, compactor)
    |> compactify!
  end

  @doc """
  Removes keys with nil values from maps, handles nested maps and treats empty maps as nil values.

  ### Examples
  ```
  iex> Morphix.compactiform(%{a: nil, b: "not", c: %{d: nil, e: %{}, f: %{g: "value"}}})
  {:ok, %{b: "not", c: %{f: %{g: "value"}}}}

  iex> Morphix.compactiform(5)
  {:error, %FunctionClauseError{arity: 1, function: :compactiform!, module: Morphix}}

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
  [[5,1], [6,2], [3], [4]]

  iex> Morphix.partiphify!(("abcdefghijklmnop" |> String.split("")), 4)
  [["", "m", "i", "e", "a"], ["n", "j", "f", "b"], ["o", "k", "g", "c"], ["p", "l", "h", "d"]]
  ```
  """
  def partiphify!(list, k) do
    buckets = (1..k)
              |> Enum.map(fn(k) -> [] end)
    list
    |> Enum.reduce({0, buckets}, fn(i, {index, buckets}) ->
      {current_bucket, rest} = List.pop_at(buckets, index)
      new_bucket = [i | current_bucket]
      {Integer.mod(index + 1, k), List.insert_at(rest, index, new_bucket)}
    end)
    |> elem(1)
  end
  
  defp empty_map(map) do
    is_map(map) && (not Map.has_key?(map, :__struct__)) && Enum.empty?(map)
  end

  defp is_struct(s), do: is_map(s) and Map.has_key?(s, :__struct__)
end
