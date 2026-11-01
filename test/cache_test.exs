defmodule Imagine.CacheTest do
  use ExUnit.Case, async: false

  alias Imagine.Cache
  alias Imagine.CmsPages.CmsPage

  setup do
    Cache.delete_all!()
    on_exit(fn -> Cache.delete_all!() end)
    :ok
  end

  test "page data is absent on a miss and preserved on a hit" do
    key = {{"cms_page", 42}}
    page = %CmsPage{id: 42, objects: [], versions: []}

    assert Cache.get!(key) == nil
    assert Cache.put!(key, page) == :ok
    assert Cache.get!(key) == page
  end

  test "invalidation removes both page data and rendered HTML" do
    page_key = {{"cms_page", 42}}
    output_key = {{"rendered_template_output", 42, 1}}
    output = {:safe, ["<p>", "Cached page", "</p>"]}

    Cache.put!(page_key, %CmsPage{id: 42})
    Cache.put!(output_key, output)
    assert Cache.get!(output_key) == output

    Cache.delete_all!()

    assert Cache.get!(page_key) == nil
    assert Cache.get!(output_key) == nil
  end
end
