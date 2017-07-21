defmodule ControlFlow do
  defmacro unless(expression, do: block) do
    quote do
      case unquote(expression) do
        false -> unquote(block)
        true -> nil
      end
    end
  end
end
