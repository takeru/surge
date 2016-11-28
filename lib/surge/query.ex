defmodule Surge.Query do

  def expression_and_values(exp, values) do
    question_replace_to_value_and_values_map(exp, %{},values, 1)
  end

  defp question_replace_to_value_and_values_map(exp, values_map, values, _) when values == [] do
    {exp, values_map}
  end
  defp question_replace_to_value_and_values_map(exp, values_map, values, n) do
    value            = List.first(values)
    added_values_map = Map.merge(values_map, %{":value#{n}" => value})
    deleted_values   = List.delete(values, value)

    exp
    |> String.replace("?", ":value#{n}", global: false)
    |> question_replace_to_value_and_values_map(added_values_map, deleted_values, n + 1)
  end


  def expression_attribute_names(key_condition_expression, model) do
    model
    |> names_of_keys
    |> expression_using_keys(key_condition_expression)
    |> expression_attribute_names_format
  end

  defp expression_attribute_names_format(key_names_of_list) do
    key_names_of_list
    |> Enum.map(fn(key) ->
      s_key = Atom.to_string(key)
      %{"##{s_key}" => s_key}
    end) |> Enum.reduce(fn(x, acc) -> Map.merge(x, acc) end)
  end

  defp expression_using_keys(keys, key_condition_expression) do
    keys
    |> Enum.map(fn(key) ->
      if String.contains?(key_condition_expression, "##{Atom.to_string(key)}") do
        key
      end
    end)
    |> Enum.reject(fn(x) -> x == nil end)
  end

  defp names_of_keys(model) do
    key_names(model.__keys__) ++ key_names(model.__secondary_keys__) ++ key_names(model.__global_keys__) |> Enum.uniq
  end

  defp key_names([hash: {hname, _htype}, range: {rname, _rtype}]) do
    [hname, rname]
  end
  defp key_names([hash: {hname, _htype}]) do
    [hname]
  end
  defp key_names(keys) when is_list(keys) do
    Enum.map(keys, fn({key, _value}) -> key end)
  end
end