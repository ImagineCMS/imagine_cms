defmodule ImagineWeb.CmsTemplateVersionController do
  use ImagineWeb, :controller

  alias Imagine.CmsTemplates
  # alias Imagine.CmsTemplates.CmsTemplateVersion

  def index(conn, params) do
    cms_template =
      params["cms_template_id"]
      |> CmsTemplates.get_cms_template!()
      |> Imagine.Repo.preload([:versions])

    render(conn, "index.html",
      cms_template: cms_template,
      cms_template_versions: cms_template.versions
    )
  end

  def show(conn, %{"id" => id} = params) do
    cms_template = CmsTemplates.get_cms_template!(params["cms_template_id"])
    cms_template_version = CmsTemplates.get_cms_template_version!(id)

    render(conn, "show.html",
      cms_template: cms_template,
      cms_template_version: cms_template_version
    )
  end
end
