defmodule ImagineWeb.CmsTemplateController do
  use ImagineWeb, :controller

  alias Imagine.CmsTemplates
  alias Imagine.CmsTemplates.CmsTemplate

  def index(conn, _params) do
    cms_templates = CmsTemplates.list_cms_templates()
    render(conn, "index.html", cms_templates: cms_templates)
  end

  def new(conn, _params) do
    changeset = CmsTemplates.change_cms_template(%CmsTemplate{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"cms_template" => cms_template_params}) do
    case CmsTemplates.create_cms_template(cms_template_params) do
      {:ok, cms_template} ->
        conn
        |> put_flash(:info, "Template created successfully.")
        |> redirect(to: Routes.cms_template_path(conn, :show, cms_template))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cms_template = CmsTemplates.get_cms_template!(id)
    render(conn, "show.html", cms_template: cms_template)
  end

  def edit(conn, %{"id" => id}) do
    cms_template = CmsTemplates.get_cms_template!(id)
    changeset = CmsTemplates.change_cms_template(cms_template)
    render(conn, "edit.html", cms_template: cms_template, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cms_template" => cms_template_params}) do
    cms_template = CmsTemplates.get_cms_template!(id)

    case CmsTemplates.update_cms_template(cms_template, cms_template_params) do
      {:ok, cms_template} ->
        changeset = CmsTemplates.change_cms_template(cms_template)

        conn
        |> put_flash(:info, "Template updated successfully.")
        |> render("edit.html", cms_template: cms_template, changeset: changeset)

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = %{changeset | action: :update}
        render(conn, "edit.html", cms_template: cms_template, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cms_template = CmsTemplates.get_cms_template!(id)
    {:ok, _cms_template} = CmsTemplates.delete_cms_template(cms_template)

    conn
    |> put_flash(:info, "Template deleted successfully.")
    |> redirect(to: Routes.cms_template_path(conn, :index))
  end
end
