defmodule Mime do
  @mimes_path Path.join([__DIR__, "mimes.txt"])


  defmacro __using__(options) do
    basic_type() ++ additional_type(options) ++ [catch_all_type()]
  end

  defp basic_type() do
    for line <- File.stream!(@mimes_path, [], :line) do
      [type, rest] =
        line
        |> String.split("\s")
        |> Enum.map(&String.strip(&1))

      extensions = String.split(rest, ~r/,\s?/)

      quote do
        def exts_from_type(unquote(type)), 
          do: unquote(extensions)
        def type_from_ext(ext) when ext in unquote(extensions), 
          do: unquote(type)
      end
    end
  end

  defp additional_type(options) do
    for {type, exts} <- options do
      type = Atom.to_string(type)
      quote do
        def exts_from_type(unquote(type)),
          do: unquote(exts)
        def type_from_ext(ext) when ext in unquote(exts),
          do: unquote(type)
      end
    end
  end

  defp catch_all_type() do
    quote do
      def exts_from_type(_type), do: []
      def type_from_ext(_ext), do: nil

      def valid_type?(type),
        do: exts_from_type(type) |> Enum.any?()
    end
  end
end

