defmodule ImagineWeb.CmsPageView do
  use ImagineWeb, :view

  alias Imagine.CmsPages
  alias Imagine.CmsPages.CmsPage

  def cms_page_browser(nil) do
    home = CmsPages.get_home_page()
    cms_page_browser(home)
  end

  def cms_page_browser(target) do
    home = CmsPages.get_home_page()
    trash = CmsPages.get_trash_page()
    cms_page_browser_columns(0, [home, trash], target)
  end

  def cms_page_browser_columns(0, pages, target) do
    [pages] ++
      cond do
        target.path == "" ->
          [Imagine.Repo.preload(Enum.at(pages, 0), sub_pages: :sub_pages).sub_pages]

        target.path == "_trash" ->
          [Enum.at(pages, 1).sub_pages]

        target.discarded_at ->
          [Enum.at(pages, 1).sub_pages]

        true ->
          sub_pages = Imagine.Repo.preload(Enum.at(pages, 0), sub_pages: :sub_pages).sub_pages
          cms_page_browser_columns(1, sub_pages, target)
      end
  end

  def cms_page_browser_columns(_level, [], _target), do: []

  def cms_page_browser_columns(level, pages, target) do
    if level > 10, do: raise("Too many levels")

    sub_pages =
      find_intermediate_page_sub_pages(
        pages,
        Enum.at(String.split(target.path, "/"), level - 1)
      )

    if target.id in Enum.map(pages, fn p -> p.id end) do
      [pages] ++ [sub_pages]
    else
      # figure out which one contains the path we need
      [pages] ++ cms_page_browser_columns(level + 1, sub_pages, target)
    end
  end

  defp find_intermediate_page_sub_pages([], _name), do: []

  defp find_intermediate_page_sub_pages([page | pages], name) do
    if page.name == name do
      Imagine.Repo.preload(page, sub_pages: :sub_pages).sub_pages
    else
      find_intermediate_page_sub_pages(pages, name)
    end
  end

  def cms_template_select_options(cms_templates) do
    for t <- cms_templates, do: {t.name, t.id}
  end

  def cms_page_select_options(cms_pages, %CmsPage{path: ""}) do
    cms_page_select_options(cms_pages)
  end

  def cms_page_select_options(cms_pages, %CmsPage{} = cms_page) do
    list =
      case cms_page.path do
        nil -> cms_pages
        _ -> Enum.reject(cms_pages, fn p -> String.starts_with?(p.path, cms_page.path) end)
      end

    cms_page_select_options(list)
  end

  def cms_page_select_options(cms_pages) do
    for t <- Enum.sort_by(cms_pages, fn p -> p.path end),
        do: {"/#{t.path} - #{t.title}", t.id}
  end

  def cms_page_version_select_options(cms_page_versions) do
    [{"[Latest]", 0}] ++
      for v <- cms_page_versions do
        {"#{v.version} - #{v.created_on} by #{v.updated_by_username}", v.version}
      end ++
      [{"[Offline]", -1}]
  end
end
