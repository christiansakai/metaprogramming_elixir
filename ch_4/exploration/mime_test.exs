Code.require_file("assertion.exs", __DIR__)
Code.require_file("mime.exs", __DIR__)

defmodule MimeTest do
  use Assertion

  defmodule MimeMapper do
    use Mime, "text/emoji": [".emj"],
              "text/elixir": [".exs"]
  end

  test "text/emoji works" do
    assert MimeMapper.exts_from_type("text/emoji") == [".emj"]
    assert MimeMapper.exts_from_type("text/elixir") == [".exs"]

    assert MimeMapper.type_from_ext(".emj") == "text/emoji"
    assert MimeMapper.type_from_ext(".exs") == "text/elixir"
  end

  test "other works too" do
    assert MimeMapper.exts_from_type("application/javascript") == [".js"]
    assert MimeMapper.exts_from_type("application/json") == [".json"]
    assert MimeMapper.exts_from_type("image/jpeg") == [".jpeg", ".jpg"]
    assert MimeMapper.exts_from_type("video/jpeg") == [".jpgv"]

    assert MimeMapper.type_from_ext(".js") == "application/javascript"
    assert MimeMapper.type_from_ext(".json") == "application/json"
    assert MimeMapper.type_from_ext(".jpeg") == "image/jpeg"
    assert MimeMapper.type_from_ext(".jpg") == "image/jpeg"
    assert MimeMapper.type_from_ext(".jpgv") == "video/jpeg"
  end

  test "catch all type works" do
    assert MimeMapper.exts_from_type("wrong") == []
    assert MimeMapper.type_from_ext(".wrong") == nil
  end
end

MimeTest.run()

