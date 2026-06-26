defmodule Imagine.HugeRTEFrontendTest do
  use ExUnit.Case, async: true

  @assets_path Path.expand("../assets", __DIR__)

  test "frontend initializes HugeRTE directly instead of legacy editor adapters" do
    source = File.read!(Path.join(@assets_path, "frontend.js"))

    assert source =~ ~s(script.src = "/assets/vendor/hugerte/hugerte.min.js")
    assert source =~ ~s(selector: ".imagine-cms-rte")
    assert source =~ "inline: true"
    assert source =~ ~s(base_url: "/assets/vendor/hugerte")
    assert source =~ "toolbar_sticky_offset: stickyOffset"
    assert source =~ ~s(extended_valid_elements: "*[*]")
    assert source =~ ~s(valid_children: "+body[style|script],+div[style|script]")
    assert source =~ ~s(addButton("cmsimage")
    assert source =~ ~s(addButton("filelink")
    assert source =~ ~s(plugins: "autolink code image link lists quickbars searchreplace table")
    assert source =~ "quickbars_insert_toolbar"
    assert source =~ "Imagine.syncEditors()"

    refute source =~ "$R("
    refute source =~ "ArticleEditor"
    refute source =~ "redactor"
  end

  test "frontend styles define HugeRTE source and inline editor affordances" do
    source = File.read!(Path.join(@assets_path, "frontend.scss"))

    assert source =~ ".imagine-cms-rte-source[hidden]"
    assert source =~ ".imagine-cms-rte"
    assert source =~ "border: 3px dashed"
    assert source =~ "scroll-margin-top: 78px"
    assert source =~ ".tox.tox-tinymce-inline"
    assert source =~ "z-index: 10010 !important"

    refute source =~ ".redactor-dropdown"
    refute source =~ ".arx-toolbar-container"
  end

  test "asset copy task copies HugeRTE runtime assets for dynamic skin loading" do
    source = File.read!(Path.expand("../lib/mix/tasks/assets.copy.ex", __DIR__))

    assert source =~ ~s(assets/node_modules/hugerte)
    assert source =~ ~s(priv/static/vendor/hugerte)
    assert source =~ ~s(assets/semantic/dist)
    assert source =~ ~s(priv/static/dist)
  end
end
