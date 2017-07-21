defmodule Assertion do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :tests, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run do
        Assertion.Test.run(@tests, __MODULE__)
      end
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)

    quote do
      @tests {unquote(test_func), unquote(description)}

      def unquote(test_func)() do
        unquote(test_block)
      end
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [
      operator: operator,
      lhs: lhs,
      rhs: rhs
    ] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
  defmacro assert(expression) do
    quote do
      Assertion.Test.assert(unquote(expression))
    end
  end

  defmacro refute({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [
      operator: operator,
      lhs: lhs,
      rhs: rhs
    ] do
      Assertion.Test.refute(operator, lhs, rhs)
    end
  end
  defmacro refute(expression) do
    quote do
      Assertion.Test.refute(unquote(expression))
    end
  end

  defmacro assert_received(message) do
    quote do
      Assertion.Test.assert_received(unquote(message))
    end
  end

  defmacro assert_raise(module, fun) do
    quote bind_quoted: [
      module: module,
      fun: fun
    ] do
      Assertion.Test.assert_raise(module, fun)
    end
  end

end

defmodule Assertion.Test do
  def run(tests, module) do
    tests
    |> Enum.map(fn {test_func, description} ->
      Task.async fn -> 
        case apply(module, test_func, []) do
          :ok           ->
            IO.write "."
            :ok
          {:fail, reason} ->
            IO.puts """
            =======================================
            FAILURE: #{description}
            =======================================
            #{reason}
            """
            :fail
        end
      end
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.reduce(%{ok: 0, fail: 0}, fn 
      (t, acc) when t == :ok -> %{acc | ok: acc.ok + 1}
      (t, acc) when t == :fail -> %{acc | fail: acc.fail + 1}
    end)
    |> (fn %{ok: ok, fail: fail} ->
      IO.puts """
      Number of successful tests are: #{ok}
      Number of failing tests are: #{fail}
      """
    end).()
  end

  def assert(:==, lhs, rhs) when lhs == rhs, do: :ok
  def assert(:==, lhs, rhs) do
    {:fail, """
      Expected:       #{lhs}
      to be equal to: #{rhs}
      """
    }
  end

  def assert(:<=, lhs, rhs) when lhs <= rhs, do: :ok
  def assert(:<=, lhs, rhs) do
    {:fail, """
      Expected:               #{lhs}
      to be less or equal to: #{rhs}
      """
    }
  end

  def assert(:<, lhs, rhs) when lhs < rhs, do: :ok
  def assert(:<, lhs, rhs) do
    {:fail, """
      Expected:           #{lhs}
      to be lesser than:  #{rhs}
      """
    }
  end

  def assert(:>=, lhs, rhs) when lhs >= rhs, do: :ok
  def assert(:>=, lhs, rhs) do
    {:fail, """
      Expected:                   #{lhs}
      to be greater or equal to:  #{rhs}
      """
    }
  end

  def assert(:>, lhs, rhs) when lhs > rhs, do: :ok
  def assert(:>, lhs, rhs) do
    {:fail, """
      Expected:           #{lhs}
      to be greater than: #{rhs}
      """
    }
  end

  def assert(true), do: :ok
  def assert(false) do
    {:fail, """
      Expected value to be true
      """
    }
  end

  def refute(:==, lhs, rhs) when lhs != rhs, do: :ok
  def refute(:==, lhs, rhs) do
    IO.puts "FAIL"
    {:fail, """
      Expected:           #{lhs}
      to not be equal to: #{rhs}
      """
    }
  end

  def refute(:<=, lhs, rhs) when lhs >= rhs, do: :ok
  def refute(:<=, lhs, rhs) do
    {:fail, """
      Expected:                   #{lhs}
      to not be less or equal to: #{rhs}
      """
    }
  end

  def refute(:<, lhs, rhs) when lhs > rhs, do: :ok
  def refute(:<, lhs, rhs) do
    {:fail, """
      Expected:               #{lhs}
      to not be lesser than:  #{rhs}
      """
    }
  end

  def refute(:>=, lhs, rhs) when lhs <= rhs, do: :ok
  def refute(:>=, lhs, rhs) do
    {:fail, """
      Expected:                       #{lhs}
      to not be greater or equal to:  #{rhs}
      """
    }
  end

  def refute(:>, lhs, rhs) when lhs < rhs, do: :ok
  def refute(:>, lhs, rhs) do
    {:fail, """
      Expected:               #{lhs}
      to not be greater than: #{rhs}
      """
    }
  end

  def refute(false), do: :ok
  def refute(true) do
    {:fail, """
      Expected value to be false
      """
    }
  end

  def assert_received(message) do
    if message in Process.info(self())[:messages] do
      :ok
    else
      {:fail, """
        Expected to receive #{message}
        """}
    end
  end

  def assert_raise(module, fun) do
    try do
      fun.()
    rescue
      KeyError -> :ok
      _ -> 
        {:fail, """
          Expected to raise #{module}
          """}
    end
  end
end
