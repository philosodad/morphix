defmodule Util.EqualityOperator do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      @doc """
      Takes two ordered or unordered elements and returns `true` if they are equal.
      It also handles nested elements.

      ### Examples:

      ```
      iex> Morphix.equaliform?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [["two", :three], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      true

      iex> Morphix.equaliform?([1, "two", :three, %{a: 1, c: "three", e: %{g: 4, b: 2}}], ["two", :three, 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      false

      ```
      """

      @spec equaliform?(any(), any()) :: boolean
      def equaliform?(tuple1, tuple2) when is_tuple(tuple1) and is_tuple(tuple2) do
        equaliform?(Tuple.to_list(tuple1), Tuple.to_list(tuple2))
      end

      def equaliform?(any1, any2) do
        equaliform?(both_enumerables?(any1, any2), any1, any2)
      end

      defp equaliform?(true, enum1, enum2), do: sort_elem(enum1) == sort_elem(enum2)
      defp equaliform?(false, any1, any2),  do: any1 == any2

      @doc """
      Takes two ordered or unordered elemets and returns `true` if they are equal.

      ### Examples:

      ```
      iex> Morphix.equalify?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [["two", :three], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      true

      iex> Morphix.equalify?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [[:three, "two"], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      false

      ```
      """

      @spec equalify?(any(), any()) :: boolean
      def equalify?(tuple1, tuple2) when is_tuple(tuple1) and is_tuple(tuple2) do
        equalify?(Tuple.to_list(tuple1), Tuple.to_list(tuple2))
      end

      def equalify?(any1, any2) do
        equalify?(both_enumerables?(any1, any2), any1, any2)
      end

      defp equalify?(true, enum1, enum2), do: Enum.sort(enum1) == Enum.sort(enum2)
      defp equalify?(false, any1, any2),  do: any1 == any2

      defp both_enumerables?(any1, any2) do
        case Enumerable.impl_for(any1) && Enumerable.impl_for(any2) do
          nil -> false
          _   -> true
        end
      end

      defp sort_elem(list) when is_list(list) do
        list
        |> Keyword.keyword?()
        |> sort_elem(list)
      end

      defp sort_elem(map) when is_map(map) do
        map
        |> Enum.reduce(%{}, fn({k, v}, acc) -> Map.put(acc, k, sort_elem(v)) end)
        |> Enum.sort()
      end

      defp sort_elem(elem), do: elem

      defp sort_elem(true, list) do
        list
        |> Enum.reduce([], fn({k, v}, acc) -> acc ++ [sort_elem(v)] end)
        |> Enum.sort()
      end

      defp sort_elem(false, list) do
        list
        |> Enum.reduce([], fn(elem, acc) -> acc ++ [sort_elem(elem)] end)
        |> Enum.sort()
      end
    end
  end
end
