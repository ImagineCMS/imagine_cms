defmodule ImagineWeb.CmsPageVersionController do
  use ImagineWeb, :controller

  alias Imagine.CmsPages

  def index(conn, params) do
    cms_page =
      params["cms_page_id"]
      |> CmsPages.get_cms_page!()
      |> Imagine.Repo.preload(versions: [:cms_template])

    render(conn, "index.html",
      cms_page: cms_page,
      cms_page_versions: cms_page.versions
    )
  end

  def show(conn, %{"id" => id} = params) do
    cms_page = CmsPages.get_cms_page!(params["cms_page_id"])
    cms_page_version = CmsPages.get_cms_page_version!(id)
    render(conn, "show.html", cms_page: cms_page, cms_page_version: cms_page_version)
  end
end
