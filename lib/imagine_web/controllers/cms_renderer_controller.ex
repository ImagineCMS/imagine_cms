defmodule ImagineWeb.CmsRendererController do
  use ImagineWeb, :controller

  alias Imagine.CmsPages
  alias Imagine.CmsPages.CmsPage
  alias Imagine.CmsTemplates
  alias Imagine.CmsTemplates.CmsTemplate
  alias Phoenix.HTML

  def show(conn, %{"path" => path_elements}) do
    case path_elements |> Enum.reverse() do
      ["edit", version, "version" | elements] ->
        path = elements |> Enum.reverse() |> Enum.join("/")
        cms_page = CmsPages.get_cms_page_by_path(path)

        redirect(conn,
          to: Routes.cms_page_path(conn, :edit_content, cms_page.id, version: version)
        )

      [version, "version" | elements] ->
        if conn.assigns[:current_user] do
          path = elements |> Enum.reverse() |> Enum.join("/")
          render_cms_page(conn, path, version)
        else
          path = [version, "version" | elements] |> Enum.reverse() |> Enum.join("/")
          redirect(conn, to: Routes.auth_path(conn, :login, return_to: "/#{path}"))
        end

      ["login" | elements] ->
        path = elements |> Enum.reverse() |> Enum.join("/")
        redirect(conn, to: Routes.auth_path(conn, :login, return_to: "/#{path}"))

      ["edit" | elements] ->
        path = elements |> Enum.reverse() |> Enum.join("/")
        cms_page = CmsPages.get_cms_page_by_path(path)
        redirect(conn, to: Routes.cms_page_path(conn, :edit_content, cms_page.id))

      _ ->
        path = path_elements |> Enum.join("/")
        render_cms_page(conn, path)
    end
  end

  defp render_cms_page(conn, path, version \\ 0)

  defp render_cms_page(%Plug.Conn{} = conn, path, version) do
    if cms_page = CmsPages.get_cms_page_by_path(path) do
      case cms_page.redirect_enabled do
        true -> redirect(conn, external: cms_page.redirect_to)
        _ -> check_cache_and_render_cms_page(conn, cms_page, version)
      end
    else
      render_404(conn)
    end
  end

  defp check_cache_and_render_cms_page(conn, cms_page, version) do
    render_uncached_cms_page(conn, cms_page, version)
  end

  defp render_uncached_cms_page(%Plug.Conn{} = conn, cms_page, version) do
    user = conn.assigns[:current_user]

    key = {{"cms_page", cms_page.id}}
    cached_result = if user, do: nil, else: Imagine.Cache.get(key)

    cms_page =
      cached_result ||
        Imagine.Cache.set(
          key,
          cms_page
          |> CmsPages.preload_objects_and_versions()
          |> Imagine.Repo.preload([:cms_template, :tags])
        )

    cms_page_version = get_requested_cms_page_version(cms_page, version)

    render_requested_cms_page_version(conn, cms_page, cms_page_version)
  end

  defp render_requested_cms_page_version(conn, nil, _), do: render_404(conn)

  defp render_requested_cms_page_version(%Plug.Conn{} = conn, cms_page, cms_page_version) do
    user = conn.assigns[:current_user]

    key = {{"rendered_template_output", cms_page.id, cms_page_version.version}}
    cached_result = if user, do: nil, else: Imagine.Cache.get(key)

    output =
      case cached_result do
        nil ->
          cms_template_content =
            get_cms_template_content(
              cms_page,
              cms_page_version.version,
              cms_page_version.cms_template_id,
              cms_page_version.cms_template_version
            )

          output = CmsTemplate.render(:view, cms_template_content, cms_page_version, conn)
          Imagine.Cache.set(key, output)

        _ ->
          cached_result
      end

    if user do
      # for properties modal
      changeset = CmsPages.change_cms_page(cms_page)
      cms_templates = CmsTemplates.list_cms_templates()
      cms_pages = CmsPages.list_cms_pages()

      render(conn, "show.html",
        # layout: layout,
        output: output,
        cms_page: cms_page,
        changeset: changeset,
        cms_templates: cms_templates,
        cms_pages: cms_pages,
        display_version_options:
          version_option_tags(cms_page.versions, "Display: ", cms_page_version.version),
        published_version_options:
          version_option_tags(cms_page.versions, "Publish: ", cms_page.published_version),
        csrf_token: Phoenix.Controller.get_csrf_token(),
        action: Routes.cms_page_path(conn, :update, cms_page)
      )
    else
      if cms_page.published_version == -1 do
        render_404(conn)
      else
        render(conn, "show.html",
          # layout: {ImagineWeb.LayoutView, "app.html"},
          output: output,
          cms_page: cms_page
        )
      end
    end
  end

  def render_404(conn) do
    # layout = {ImagineWeb.LayoutView, "app.html"}
    render(put_status(conn, :not_found), "404.html", cms_page: nil)
    # layout: layout)
  end

  defp get_requested_cms_page_version(nil, _), do: nil
  defp get_requested_cms_page_version(cms_page, version) when version == 0, do: cms_page

  defp get_requested_cms_page_version(%CmsPage{version: pg_version} = cms_page, version)
       when version == pg_version,
       do: cms_page

  defp get_requested_cms_page_version(%CmsPage{} = cms_page, version) do
    cms_page.path
    |> CmsPages.get_cms_page_by_path_with_objects(version)
    |> Imagine.Repo.preload([:cms_template, :tags])
  end

  # if page version is latest (0 or pg_version), use latest template version.
  # this is a legacy behavior, but one which I believe is still the least
  # surprising (no need to re-save all pages to see template changes)
  defp get_cms_template_content(%CmsPage{} = cms_page, 0, _, _),
    do: cms_page.cms_template.content_eex

  defp get_cms_template_content(%CmsPage{version: pg_version} = cms_page, version, _, _)
       when version == pg_version,
       do: cms_page.cms_template.content_eex

  defp get_cms_template_content(_, _, cms_template_id, cms_template_version) do
    CmsTemplates.get_cms_template_version_by(
      cms_template_id: cms_template_id,
      version: cms_template_version
    ).content_eex
  end

  defp version_option_tags(versions, prefix, selected) do
    version_tuples =
      Enum.map(versions, fn v ->
        {v.version, "#{prefix}#{v.version} - #{v.updated_on} by #{v.updated_by_username}"}
      end)

    version_tuples =
      case prefix do
        "Publish: " -> [{0, "Publish: [Latest]"}] ++ version_tuples ++ [{-1, "[Offline]"}]
        _ -> version_tuples
      end

    for {version, str} <- version_tuples,
        do: HTML.Tag.content_tag(:option, str, value: version, selected: version == selected)
  end
end
