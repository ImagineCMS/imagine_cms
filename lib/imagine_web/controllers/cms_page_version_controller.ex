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

  def show(conn, %{"id" => id, "cms_page_id" => cms_page_id}) do
    cms_page = CmsPages.get_cms_page!(cms_page_id)

    cms_page_version =
      CmsPages.get_cms_page_version!(id)
      |> Imagine.Repo.preload([:cms_template, :parent, :author])

    render(conn, "show.html", cms_page: cms_page, cms_page_version: cms_page_version)
  end

  def delete(conn, %{"id" => id, "cms_page_id" => cms_page_id}) do
    cms_page = CmsPages.get_cms_page!(cms_page_id)
    cms_page_version = CmsPages.get_cms_page_version!(id)

    unless cms_page.version == cms_page_version.version ||
             cms_page.published_version == cms_page_version.version do
      {:ok, cms_page_version} = CmsPages.delete_cms_page_version(cms_page_version)

      conn
      |> put_flash(:info, "Version #{cms_page_version.version} deleted successfully.")
      |> redirect(to: Routes.cms_page_path(conn, :show, cms_page))
    end
  end
end
