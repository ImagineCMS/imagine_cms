defmodule Imagine.CmsTemplates.RenderViewHelpers do
  @moduledoc """
  Defines CMS template helpers like text_editor in View mode (i.e. the rendered output)
  """

  use Phoenix.HTML

  alias Imagine.CmsPages
  alias Imagine.CmsPages.{CmsPage, CmsPageObject}
  # alias Imagine.CmsTemplates
  alias Imagine.CmsTemplates.CmsTemplate
  alias Imagine.Repo

  # add shortened, @conn-free versions of all the helpers to make templates look nicer
  defmacro text_editor(obj_name, opts \\ []) when is_binary(obj_name) do
    quote do
      text_editor(var!(assigns)[:conn], unquote(obj_name), unquote(opts))
    end
  end

  defmacro snippet(obj_name, opts \\ []) when is_binary(obj_name) do
    quote do
      snippet(var!(assigns)[:conn], unquote(obj_name), unquote(opts))
    end
  end

  defmacro page_list(obj_name, opts \\ []) when is_binary(obj_name) do
    quote do
      page_list(var!(assigns)[:conn], unquote(obj_name), unquote(opts))
    end
  end

  def text_editor(%Plug.Conn{assigns: %{cms_page: cms_page}}, obj_name, _opts) do
    obj =
      cms_page
      |> CmsPageObject.extract_page_objects_from_page()
      |> CmsPageObject.find_object(obj_name, "text")

    case obj do
      nil -> nil
      _ -> raw(obj.content)
    end
  end

  # def text_editor(_conn, _, _) do
  #   {:safe,
  #    "text_editor(): Invalid arguments provided. First argument should be @conn. Second argument should be a name."}
  # end

  def snippet(%Plug.Conn{} = conn, obj_name, _opts) do
    cms_page = conn.assigns[:cms_page] || %CmsPage{}
    snippet = Imagine.CmsTemplates.get_cms_snippet_by_name(obj_name)

    case snippet do
      nil -> "Could not find snippet \"#{obj_name}\" in the database."
      _ -> CmsTemplate.render(:edit, snippet.content_eex, cms_page, conn)
    end
  end

  def sort_pages(pages, _, :random) do
    Enum.shuffle(pages)
  end

  def sort_pages(pages, key1, :asc) do
    Enum.sort(pages, &cmp_asc(&1, &2, key1))
  end

  def sort_pages(pages, key1, :desc) do
    Enum.sort(pages, &cmp_desc(&1, &2, key1))
  end

  # def sort_pages(pages, key1, key1dir, key2, key2dir) do
  #   Enum.sort(pages, &cmp_asc(&1, &2, key1))
  # end

  def cmp_eq(a, b, key) when is_binary(key), do: cmp_eq(a, b, String.to_existing_atom(key))

  def cmp_eq(a, b, key) do
    Map.get(a, key) == Map.get(b, key)
  end

  def cmp_lt(a = %NaiveDateTime{}, b = %NaiveDateTime{}), do: NaiveDateTime.compare(a, b) != :gt
  def cmp_lt(a, b), do: a <= b

  def cmp_asc(a, b, key) do
    cmp_lt(Map.get(a, key), Map.get(b, key))
  end

  def cmp_desc(b, a, key) do
    cmp_lt(Map.get(a, key), Map.get(b, key))
  end

  def page_list(%Plug.Conn{assigns: %{cms_page: cms_page}}, obj_name, opts) do
    pages = gather_pages_from_folders(opts[:folders])
    # TODO: combine with pages from tags

    pages =
      sort_pages(
        pages,
        opts[:primary_sort_key] || :article_date,
        opts[:primary_sort_direction] || :desc
      )
      |> Enum.drop(opts[:item_offset] || 0)
      |> Enum.take(opts[:item_count] || 10)

    output = render_page_list(pages, cms_page, opts)

    id = "PageList-#{obj_name}-container"
    class = "Imagine-CmsPageObject-PageList"

    content_tag :div, id: id, class: class do
      raw(output)
    end
  end

  def render_page_list(pages, containing_page, opts) do
    [
      hbrender(opts[:header], containing_page),
      render_page_list_pages(pages, containing_page, opts),
      hbrender(opts[:footer], containing_page)
    ]
  end

  def hbrender(nil, _context), do: ""

  def hbrender(content, context) do
    NodeJS.call!("hbrender", [content, context], binary: true)
  end

  def render_page_list_pages(cms_pages, containing_page, opts, index \\ 1)
  def render_page_list_pages([], _containing_page, _opts, _index), do: []

  def render_page_list_pages([cms_page | cms_pages], containing_page, opts, index) do
    context =
      cms_page
      |> Map.put(:containing_page, containing_page)
      |> Map.put(:index, index)

    # NOTE: the Jason encoder ultimately determines which attributes are exposed to hbrender
    output = hbrender(opts[:template], context)
    [output, render_page_list_pages(cms_pages, containing_page, opts, index + 1)]
  end

  def gather_pages_from_folders(folders) when is_binary(folders) do
    gather_pages_from_folders(folders |> String.split(",") |> Enum.map(&String.trim/1))
  end

  def gather_pages_from_folders(nil), do: []
  def gather_pages_from_folders([]), do: []

  def gather_pages_from_folders([folder | folders]) do
    cms_page =
      folder
      |> CmsPages.get_cms_page_by_path()
      |> Repo.preload(:sub_pages)

    sub_pages =
      case cms_page do
        # can be nil when page list is pointed at a non-existent path
        nil -> []
        _ -> cms_page.sub_pages
      end

    sub_pages ++ gather_pages_from_folders(folders)
  end

  def template_option(_opt_name, :string) do
    "template_option(opt_name, :string) not implemented yet"
  end

  def template_option(_opt_name, :checkbox, do: _expression) do
    "template_option(opt_name, :checkbox) not implemented yet"
  end

  #
  # older insert_object syntax
  #
  # defmacro insert_object(obj_name, type, opts \\ [])

  # defmacro insert_object(obj_name, :text, opts) do
  #   text_editor(obj_name, opts)
  # end

  # defmacro insert_object(obj_name, :snippet, opts) do
  #   snippet(obj_name, opts)
  # end

  # defmacro insert_object(conn, obj_name, :page_list, opts) do
  #   page_list(obj_name, opts)
  # end

  def render(_conn, [partial: _partial_path] = _opts) do
    "render(partial: ...) not implemented yet"
  end
end
