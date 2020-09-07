defmodule ImagineWeb.CmsSnippetVersionController do
  use ImagineWeb, :controller

  alias Imagine.CmsTemplates
  # alias Imagine.CmsTemplates.CmsSnippetVersion

  def index(conn, params) do
    cms_snippet =
      params["cms_snippet_id"]
      |> CmsTemplates.get_cms_snippet!()
      |> Imagine.Repo.preload([:versions])

    render(conn, "index.html",
      cms_snippet: cms_snippet,
      cms_snippet_versions: cms_snippet.versions
    )
  end

  def show(conn, %{"id" => id} = params) do
    cms_snippet = CmsTemplates.get_cms_snippet!(params["cms_snippet_id"])
    cms_snippet_version = CmsTemplates.get_cms_snippet_version!(id)
    render(conn, "show.html", cms_snippet: cms_snippet, cms_snippet_version: cms_snippet_version)
  end
end
