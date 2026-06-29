defmodule Imagine.CmsTemplates.Handlebars do
  @moduledoc """
  Minimal Handlebars-compatible interpolation for CMS page-list templates.

  The CMS only uses Handlebars for page-list fragments. This renderer supports
  escaped variables (`{{title}}`), raw variables (`{{{html}}}`), dotted paths,
  and missing values as empty strings.
  """

  @expression ~r/{{{\s*([^{}]+?)\s*}}}|{{\s*([^{}]+?)\s*}}/

  def render(nil, _context), do: ""

  def render(content, context) when is_binary(content) do
    context = normalize_context(context)

    Regex.replace(@expression, content, fn
      _match, raw_path, "" ->
        raw_path
        |> resolve(context)
        |> stringify()

      _match, "", escaped_path ->
        escaped_path
        |> resolve(context)
        |> stringify()
        |> escape_expression()
    end)
  end

  defp normalize_context(context) do
    context
    |> Jason.encode!()
    |> Jason.decode!()
  end

  defp resolve(path, context) do
    path
    |> String.trim()
    |> String.split(".", trim: true)
    |> do_resolve(context)
  end

  defp do_resolve([], value), do: value
  defp do_resolve(["this" | path], value), do: do_resolve(path, value)
  defp do_resolve(["." | path], value), do: do_resolve(path, value)
  defp do_resolve(["" | path], value), do: do_resolve(path, value)

  defp do_resolve([key | path], %{} = value) do
    do_resolve(path, Map.get(value, key))
  end

  defp do_resolve(_path, _value), do: nil

  defp stringify(nil), do: ""
  defp stringify(value) when is_binary(value), do: value
  defp stringify(value), do: to_string(value)

  defp escape_expression(value) do
    String.replace(value, ~r/[&<>"'`=]/, fn
      "&" -> "&amp;"
      "<" -> "&lt;"
      ">" -> "&gt;"
      ~s(") -> "&quot;"
      "'" -> "&#x27;"
      "`" -> "&#x60;"
      "=" -> "&#x3D;"
    end)
  end
end
