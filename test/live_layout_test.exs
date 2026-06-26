defmodule ImagineWeb.LiveLayoutTest do
  use ExUnit.Case, async: true

  test "live layout renders flash through Phoenix.Flash" do
    output =
      Phoenix.View.render(ImagineWeb.LayoutView, "live.html",
        inner_content: "Inner",
        flash: %{"info" => "Saved", "error" => "Nope"}
      )

    html = Phoenix.LiveViewTest.rendered_to_string(output)

    assert html =~ "Saved"
    assert html =~ "Nope"
    assert html =~ "Inner"
  end
end
