defmodule MathTest do
  use Assertion

  test "integers can be added and subtracted" do
    assert 1 + 1 == 2
    assert 2 + 3 == 5
    assert 5 - 5 == 10
    assert true
  end

  test "integers can be multiplied and divided" do
    assert 5 * 5 == 25
    assert 10 / 2 == 5
    assert false
  end

  test "integers can be added and subtracted (refute version)" do
    refute 1 + 1 == 2
    refute 2 + 3 == 5
    refute 5 - 5 == 10
    refute true
  end

  test "integers can be multiplied and divided (refute version)" do
    refute 5 * 5 == 25
    refute 10 / 2 == 5
    refute false
  end
end
