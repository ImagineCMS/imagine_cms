defmodule ImagineWeb.Live.CmsPage.Browser do
  @moduledoc """
  Live View implementation for cms page column browser
  """

  use Phoenix.LiveView

  alias Imagine.Repo
  alias Imagine.CmsPages
  alias Imagine.CmsTemplates

  alias ImagineWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(ImagineWeb.CmsPageView, "browser.html", assigns)
  end

  def mount(_, session, socket) do
    cms_page = get_page(session["cms_page_id"])

    socket =
      socket
      |> assign(
        user: session["current_user"],
        cms_page: cms_page,
        properties_modal: "",
        timestamp: Time.utc_now(),
        csrf_token: session["csrf_token"]
      )

    {:ok, socket}
  end

  def handle_event("new-page", %{"cms-page-id" => cms_page_id}, socket) do
    user = socket.assigns[:user]
    parent = get_page(cms_page_id)

    attrs = %{
      name: "new-page",
      title: "My New Page",
      cms_template_id: parent.cms_template_id,
      parent_id: parent.id,
      position: 1
    }

    {:ok, new_page} = CmsPages.create_cms_page(attrs, user)

    {:noreply, assign(socket, cms_page: Repo.preload(new_page, [:versions, :sub_pages]))}
  end

  def handle_event("select-page", %{"cms-page-id" => "_trash"}, socket) do
    {:noreply, assign(socket, cms_page: CmsPages.get_trash_page(), properties_modal: "")}
  end

  def handle_event("select-page", %{"cms-page-id" => cms_page_id}, socket) do
    {:noreply, assign(socket, cms_page: get_page(cms_page_id), properties_modal: "")}
  end

  def handle_event("properties", _values, socket) do
    cms_page = socket.assigns[:cms_page]

    changeset = CmsPages.change_cms_page(cms_page)
    action = Routes.cms_page_path(socket, :update, cms_page)
    cms_templates = CmsTemplates.list_cms_templates()

    cms_pages = CmsPages.list_cms_pages()

    socket =
      assign(socket,
        changeset: changeset,
        action: action,
        cms_templates: cms_templates,
        cms_pages: cms_pages,
        timestamp: Time.utc_now(),
        return_to: Routes.cms_page_path(socket, :index)
      )

    output = Phoenix.View.render(ImagineWeb.CmsPageView, "_properties_modal.html", socket.assigns)

    {:noreply, assign(socket, :properties_modal, output)}
  end

  def handle_event("delete-page", %{"cms-page-id" => cms_page_id}, socket) do
    {:ok, cms_page} =
      cms_page_id
      |> CmsPages.get_cms_page!()
      |> CmsPages.delete_cms_page()

    {:noreply, assign(socket, cms_page: get_page(cms_page.parent_id))}
  end

  def handle_event("undelete-page", %{"cms-page-id" => cms_page_id}, socket) do
    {:ok, _cms_page} =
      cms_page_id
      |> CmsPages.get_cms_page!(include_deleted: true)
      |> CmsPages.undelete_cms_page()

    {:noreply, assign(socket, cms_page: get_page(cms_page_id))}
  end

  def handle_event("destroy-page", %{"cms-page-id" => cms_page_id}, socket) do
    {:ok, _cms_page} =
      cms_page_id
      |> CmsPages.get_cms_page!(include_deleted: true)
      |> CmsPages.destroy_cms_page()

    {:noreply, assign(socket, cms_page: get_page("_trash"))}
  end

  defp get_page("_trash") do
    CmsPages.get_trash_page()
  end

  defp get_page(nil) do
    CmsPages.get_home_page!()
    |> Repo.preload([:sub_pages, :versions])
  end

  defp get_page(cms_page_id) do
    (CmsPages.get_cms_page(cms_page_id, include_deleted: true) ||
       CmsPages.get_home_page!())
    |> Repo.preload([:sub_pages, :versions])
  end
end
