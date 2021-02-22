defmodule ImagineWeb.CmsPageController do
  use ImagineWeb, :controller

  alias Imagine.Repo
  alias Imagine.CmsPages
  alias Imagine.CmsPages.CmsPage
  alias Imagine.CmsTemplates
  alias Imagine.CmsTemplates.CmsTemplate

  def index(conn, params) do
    cms_pages =
      CmsPages.list_recent_cms_pages(10)
      |> Repo.preload(:cms_template)

    conn
    |> set_page_id_in_session(params["cms_page_id"])
    |> render("index.html", cms_pages: cms_pages)
  end

  def new(conn, params) do
    parent_id = params["parent_id"]

    conn = put_session(conn, :cms_page_id, parent_id)

    changeset =
      CmsPages.change_cms_page(%CmsPage{
        published_date: NaiveDateTime.utc_now(),
        position: 1,
        parent_id: parent_id
      })

    cms_templates = CmsTemplates.list_cms_templates()
    cms_pages = CmsPages.list_cms_pages()

    render(conn, "new.html",
      changeset: changeset,
      cms_templates: cms_templates,
      cms_pages: cms_pages
    )
  end

  def create(conn, %{"cms_page" => cms_page_params}) do
    current_user = conn.assigns[:current_user]

    case CmsPages.create_cms_page(cms_page_params, current_user) do
      {:ok, cms_page} ->
        conn
        |> put_flash(:info, "Page created successfully.")
        |> put_session(:cms_page_id, cms_page.id)
        |> redirect(to: Routes.cms_page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        cms_templates = CmsTemplates.list_cms_templates()
        cms_pages = CmsPages.list_cms_pages()

        render(conn, "new.html",
          changeset: changeset,
          cms_templates: cms_templates,
          cms_pages: cms_pages
        )
    end
  end

  def show(conn, %{"id" => id}) do
    cms_page =
      CmsPages.get_cms_page!(id, include_deleted: true)
      |> Repo.preload([:sub_pages, :cms_template, :parent, :author])

    conn = put_session(conn, :cms_page_id, cms_page.id)
    render(conn, "show.html", cms_page: cms_page)
  end

  def edit(conn, %{"id" => id}) do
    cms_page = CmsPages.get_cms_page!(id, preload_versions: true)
    conn = put_session(conn, :cms_page_id, cms_page.id)

    changeset = CmsPages.change_cms_page(cms_page)
    cms_templates = CmsTemplates.list_cms_templates()
    cms_pages = CmsPages.list_cms_pages()

    render(conn, "edit.html",
      cms_page: cms_page,
      changeset: changeset,
      cms_templates: cms_templates,
      cms_pages: cms_pages
    )
  end

  def update(conn, %{"id" => id, "cms_page" => cms_page_params} = params) do
    cms_page = CmsPages.get_cms_page!(id)
    current_user = conn.assigns[:current_user]

    return_to = params["return_to"] || Routes.cms_page_path(conn, :index)

    case CmsPages.update_cms_page(cms_page, cms_page_params, false, current_user) do
      {:ok, cms_page} ->
        conn
        |> put_flash(:info, "Page properties saved.")
        |> put_session(:cms_page_id, cms_page.id)
        |> redirect(to: return_to)

      {:error, %Ecto.Changeset{} = changeset} ->
        cms_page = CmsPages.get_cms_page!(id, preload_versions: true)
        cms_templates = CmsTemplates.list_cms_templates()
        cms_pages = CmsPages.list_cms_pages()

        render(conn, "edit.html",
          cms_page: cms_page,
          changeset: changeset,
          cms_templates: cms_templates,
          cms_pages: cms_pages
        )
    end
  end

  def edit_content(conn, %{"id" => id} = params) do
    version = params["version"]

    cms_page = CmsPages.get_cms_page_with_objects!(id, version)
    output = CmsTemplate.render(:edit, cms_page.cms_template.content_eex, cms_page, conn)

    conn
    |> set_page_id_in_session(params["id"])
    |> render("edit_content.html",
      output: output,
      cms_page: cms_page,
      version: version,
      csrf_token: get_csrf_token()
    )
  end

  def update_content(conn, %{"id" => id} = params) do
    current_user = conn.assigns[:current_user]
    version = params["version"]

    cms_page = CmsPages.get_cms_page_with_objects!(id, version)

    # FIXME: Create something like CmsPages.update_cms_page_and_objects that uses Ecto.Multi
    {:ok, new_cms_page} =
      CmsPages.update_cms_page(CmsPages.get_cms_page!(id), %{}, true, current_user)

    attrses = build_attrs_list(cms_page.objects, params["cms_page"]["objects"])
    CmsPages.update_cms_page_objects(cms_page.objects, attrses, new_cms_page.version)

    redirect(conn, to: "/#{cms_page.path}")
  end

  def set_published_version(conn, %{"id" => id, "version" => version}) do
    cms_page = CmsPages.get_cms_page!(id)
    current_user = conn.assigns[:current_user]

    attrs = %{"published_version" => version}

    {:ok, _updated_cms_page} = CmsPages.update_cms_page(cms_page, attrs, false, current_user)

    resp(conn, 200, "success")
  end

  def delete(conn, %{"id" => id}) do
    {:ok, cms_page} = id |> CmsPages.get_cms_page!() |> CmsPages.delete_cms_page()

    conn
    |> put_flash(:info, "Page moved to trash.")
    |> put_session(:cms_page_id, cms_page.parent_id)
    |> redirect(to: Routes.cms_page_path(conn, :index))
  end

  def undelete(conn, %{"id" => id}) do
    {:ok, cms_page} =
      id
      |> CmsPages.get_cms_page!(include_deleted: true)
      |> CmsPages.undelete_cms_page()

    conn
    |> put_flash(:info, "Page restored to original location.")
    |> put_session(:cms_page_id, cms_page.id)
    |> redirect(to: Routes.cms_page_path(conn, :index))
  end

  def destroy(conn, %{"id" => id}) do
    {:ok, _cms_page} =
      id
      |> CmsPages.get_cms_page!(include_deleted: true)
      |> CmsPages.destroy_cms_page()

    conn
    |> put_flash(:info, "Page deleted permanently.")
    |> put_session(:cms_page_id, "_trash")
    |> redirect(to: Routes.cms_page_path(conn, :index))
  end

  defp set_page_id_in_session(conn, nil), do: conn
  defp set_page_id_in_session(conn, page_id), do: put_session(conn, :cms_page_id, page_id)

  defp build_attrs_list(objects, obj_params) do
    objects
    |> Enum.map(fn obj -> to_string(obj.id) end)
    |> Enum.map(fn id -> obj_params[id] end)
  end
end
