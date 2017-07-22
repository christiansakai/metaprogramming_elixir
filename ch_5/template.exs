defmodule Template do
  import Html

  def render do
    markup do
      table do
        tr do
          for i <- 0..5 do
            td do: text("Cell #{i}")
          end
        end
      end

      div do
        text "Some Nested Content"
      end
    end
  end

  def render2 do
    markup do
      div id: "main" do
        h1 class: "title" do
          text "Welcome!"
        end
      end

      div class: "row" do
        div do
          p do: text "Hello!"
        end
      end
    end
  end
end
