defmodule ImagineWeb.CmsSnippetController do
  use ImagineWeb, :controller

  alias Imagine.CmsTemplates
  alias Imagine.CmsTemplates.CmsSnippet

  def index(conn, _params) do
    cms_snippets = CmsTemplates.list_cms_snippets()
    render(conn, "index.html", cms_snippets: cms_snippets)
  end

  def new(conn, _params) do
    changeset = CmsTemplates.change_cms_snippet(%CmsSnippet{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"cms_snippet" => cms_snippet_params}) do
    case CmsTemplates.create_cms_snippet(cms_snippet_params) do
      {:ok, cms_snippet} ->
        conn
        |> put_flash(:info, "Snippet created successfully.")
        |> redirect(to: Routes.cms_snippet_path(conn, :show, cms_snippet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cms_snippet = CmsTemplates.get_cms_snippet!(id)
    render(conn, "show.html", cms_snippet: cms_snippet)
  end

  def edit(conn, %{"id" => id}) do
    cms_snippet = CmsTemplates.get_cms_snippet!(id)
    changeset = CmsTemplates.change_cms_snippet(cms_snippet)
    render(conn, "edit.html", cms_snippet: cms_snippet, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cms_snippet" => cms_snippet_params}) do
    cms_snippet = CmsTemplates.get_cms_snippet!(id)

    case CmsTemplates.update_cms_snippet(cms_snippet, cms_snippet_params) do
      {:ok, cms_snippet} ->
        changeset = CmsTemplates.change_cms_snippet(cms_snippet)

        conn
        |> put_flash(:info, "Snippet updated successfully.")
        |> render("edit.html", cms_snippet: cms_snippet, changeset: changeset)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", cms_snippet: cms_snippet, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cms_snippet = CmsTemplates.get_cms_snippet!(id)
    {:ok, _cms_snippet} = CmsTemplates.delete_cms_snippet(cms_snippet)

    conn
    |> put_flash(:info, "Snippet deleted successfully.")
    |> redirect(to: Routes.cms_snippet_path(conn, :index))
  end
end
