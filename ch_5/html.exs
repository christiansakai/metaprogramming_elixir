defmodule Html do
  @external_resource tags_path = Path.join([__DIR__, "tags.txt"])

  @tags (for line <- File.stream!(tags_path, [], :line) do
    line
    |> String.strip()
    |> String.to_atom()
  end)

  defmacro markup(do: block) do 
    quote do
      {:ok, var!(buffer, Html)} = start_buffer([])
      unquote(Macro.postwalk(block, &postwalk/1))
      result = render(var!(buffer, Html))
      :ok = stop_buffer(var!(buffer, Html))
      result
    end
  end

  def postwalk({:text, _meta, [string]}) do
    quote do
      put_buffer(var!(buffer, Html), to_string(unquote(string)))
    end
  end

  def postwalk({tag_name, _meta, [[do: inner]]}) when tag_name in @tags do
    quote do
      tag(unquote(tag_name), [], do: unquote(inner))
    end
  end

  def postwalk({tag_name, _meta, [attrs, [do: inner]]}) when tag_name in @tags do
    quote do
      tag(unquote(tag_name), unquote(attrs), do: unquote(inner))
    end
  end

  def postwalk(ast), do: ast

  defmacro tag(name, attrs \\ [], do: inner) do
    quote do
      put_buffer(var!)
      unquote(postwalk(inner))
      put_buffer(var!(buffer, Html), unquote("</#{name}>"))
    end
  end

  def open_tag(name, []), do: "<#{name}>"
  def open_tag(name, attrs) do
    attr_html = 
      for {key, val} <- attrs, 
        into: "", 
        do: " #{key}=\"#{val}\""

    "<#{name}#{attr_html}>"
  end

  def start_buffer(state), 
    do: Agent.start_link(fn -> state end) 

  def stop_buffer(buff), 
    do: Agent.stop(buff)

  def put_buffer(buff, content), 
    do: Agent.update(buff, &[content | &1]) 

  def render(buff) do
    buff
    |> Agent.get(&(&1)) 
    |> Enum.reverse() 
    |> Enum.join("") 
  end

end
