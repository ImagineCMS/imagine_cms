defmodule Imagine.CmsPages do
  @moduledoc """
  The CmsPages context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Imagine.Repo

  alias Imagine.CmsPages.{CmsPage, CmsPageObject, CmsPageTag, CmsPageVersion}

  # alias Imagine.Accounts.User

  @doc """
  Returns the list of cms_pages.

  ## Examples

      iex> list_cms_pages()
      [%CmsPage{}, ...]

  """
  def list_cms_pages(order_by \\ [asc: :path], limit \\ 1000) do
    Repo.all(from p in active_pages_query(), order_by: ^order_by, limit: ^limit)
  end

  def list_recent_cms_pages(limit \\ 10) do
    Repo.all(from p in active_pages_query(), order_by: [desc: :updated_on], limit: ^limit)
  end

  def active_pages_query do
    from(p in CmsPage, where: is_nil(p.discarded_at), preload: [:sub_pages])
  end

  def active_versions_query do
    from(v in CmsPageVersion, where: is_nil(v.discarded_at))
  end

  def discarded_pages_query do
    from(p in CmsPage, where: not is_nil(p.discarded_at))
  end

  def list_discarded_cms_pages do
    Repo.all(from p in discarded_pages_query(), order_by: [desc: :discarded_at])
  end

  def get_home_page do
    Repo.get_by(active_pages_query(), path: "") || Repo.get(CmsPage, 1)
  end

  def get_trash_page do
    %CmsPage{
      id: "_trash",
      name: "_trash",
      path: "_trash",
      discarded_at: NaiveDateTime.utc_now(),
      sub_pages:
        list_discarded_cms_pages()
        |> Enum.map(fn p -> %{p | path: "_trash/#{p.name}", sub_pages: []} end)
    }
  end

  @doc """
  Gets a single cms_page.

  Raises `Ecto.NoResultsError` if the Cms page does not exist.

  ## Examples

      iex> get_cms_page!(123)
      %CmsPage{}

      iex> get_cms_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page!(id),
    do: Repo.get!(active_pages_query(), id)

  def get_cms_page!(id, opts) do
    queryable =
      case opts[:include_deleted] do
        true -> CmsPage
        _ -> active_pages_query()
      end

    ret = Repo.get!(queryable, id)

    ret =
      case opts[:preload_versions] do
        true ->
          ret
          |> Repo.preload(
            versions:
              from(v in CmsPageVersion,
                where: is_nil(v.discarded_at),
                order_by: [desc: v.version],
                select: [:id, :version, :updated_by, :updated_by_username]
              )
          )

        _ ->
          ret
      end

    ret
  end

  def get_cms_page(id),
    do: Repo.get(active_pages_query(), id)

  def get_cms_page(id, include_deleted: true),
    do: Repo.get(CmsPage, id)

  def get_cms_page_with_objects!(id, version \\ nil)
  def get_cms_page_with_objects!(id, ""), do: get_cms_page_with_objects!(id, nil)

  def get_cms_page_with_objects!(id, nil) do
    id
    |> get_cms_page!
    |> get_published_version
    |> preload_objects_and_versions()
  end

  def get_cms_page_with_objects!(id, version) do
    get_cms_page_version_by(cms_page_id: id, version: version)
    |> preload_objects_and_versions()
  end

  def get_cms_page_by_path(nil), do: get_home_page()
  def get_cms_page_by_path(""), do: get_home_page()

  def get_cms_page_by_path(path) do
    Repo.get_by(active_pages_query(), path: path)
  end

  def get_cms_page_by_path_for_nav(path) do
    Repo.get_by(active_pages_query(), path: to_string(path))
    |> Repo.preload(sub_pages: [:sub_pages])
  end

  def get_cms_page_version_by(params) do
    if Keyword.has_key?(params, :path) do
      case params[:path] do
        nil -> get_home_page_version_by(Keyword.delete(params, :path))
        "" -> get_home_page_version_by(Keyword.delete(params, :path))
        path -> get_cms_page_version_by(get_cms_page_by_path(path), Keyword.delete(params, :path))
      end
    else
      Repo.get_by(active_versions_query(), params)
    end
  end

  def get_cms_page_version_by(nil, _), do: nil

  def get_cms_page_version_by(cms_page, params) do
    Repo.get_by(from(v in active_versions_query(), where: v.cms_page_id == ^cms_page.id), params)
  end

  def get_home_page_version_by(params), do: get_home_page() |> get_cms_page_version_by(params)

  def get_cms_page_by_path_with_objects(path, version \\ nil)

  def get_cms_page_by_path_with_objects(path, nil) do
    path
    |> get_cms_page_by_path
    |> get_published_version
    |> preload_objects_and_versions()
  end

  def get_cms_page_by_path_with_objects(path, version) do
    get_cms_page_version_by(path: path, version: version)
    |> preload_objects_and_versions()
  end

  defp get_published_version(%CmsPage{published_version: v} = page),
    do: get_published_version(page, v)

  defp get_published_version(_, nil), do: nil
  defp get_published_version(_, -1), do: nil
  defp get_published_version(page, 0), do: page

  defp get_published_version(page, version) do
    get_cms_page_version_by(path: page.path, version: version)
  end

  def preload_objects_and_versions(nil), do: nil

  def preload_objects_and_versions(%{version: version} = page_or_version) do
    page_or_version
    |> Repo.preload([:sub_pages, :cms_template, :tags])
    |> Repo.preload(
      objects: from(o in CmsPageObject, where: o.cms_page_version == ^version),
      versions:
        from(v in CmsPageVersion,
          where: is_nil(v.discarded_at),
          order_by: [desc: v.version],
          select: [:id, :version, :updated_by, :updated_by_username, :created_on]
        )
    )
  end

  @doc """
  Creates a cms_page.

  ## Examples

      iex> create_cms_page(%{field: value})
      {:ok, %CmsPage{}}

      iex> create_cms_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page(attrs, current_user, iteration \\ 0) do
    # if this isn't the first time, there was a naming conflict, try again
    new_attrs =
      case iteration do
        0 -> attrs
        i -> Map.put(attrs, :name, "#{attrs[:name]}-#{i}")
      end

    # changeset calculates path, we can use that to check for duplicates
    changeset =
      %CmsPage{}
      |> CmsPage.changeset(new_attrs, true, current_user)

    if iteration < 100 && get_cms_page_by_path(changeset.changes.path) do
      create_cms_page(attrs, current_user, iteration + 1)
    else
      result = Repo.insert(changeset)

      case result do
        {:ok, new_cms_page} ->
          {:ok, _version} = create_cms_page_version(new_cms_page)
          result

        _ ->
          result
      end
    end
  end

  @doc """
  Updates a cms_page, optionally creating a new version (third argument). When creating a new version,
  the fourth argument should be the Imagine.Accounts.User who made the change.

  ## Examples

      iex> update_cms_page(cms_page, %{field: new_value})
      {:ok, %CmsPage{}}

      iex> update_cms_page(cms_page, %{field: bad_value}, true, current_user)
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_page(
        %CmsPage{} = cms_page,
        attrs,
        save_new_version \\ false,
        current_user \\ nil
      ) do
    changeset = CmsPage.changeset(cms_page, attrs, save_new_version, current_user)

    result = Repo.update(changeset)

    case result do
      {:ok, new_cms_page} ->
        # do not combine the case statements; both could be true
        case changeset do
          %{changes: %{parent_id: _new_parent_id}} ->
            CmsPage.update_descendant_paths(new_cms_page)

          %{changes: %{path: _new_path}} ->
            from(v in CmsPageVersion, where: v.cms_page_id == ^new_cms_page.id)
            |> Repo.update_all(set: [path: new_cms_page.path])

            CmsPage.update_descendant_paths(new_cms_page)

          _ ->
            nil
        end

        case changeset do
          %{changes: %{version: _new_version}} ->
            {:ok, _version} = create_cms_page_version(new_cms_page)

          _ ->
            nil
        end

      _ ->
        nil
    end

    Imagine.Cache.flush()

    result
  end

  @doc """
  Deletes a CmsPage.

  ## Examples

      iex> delete_cms_page(cms_page)
      {:ok, %CmsPage{}}

      iex> delete_cms_page(cms_page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_page(%CmsPage{} = cms_page) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    result =
      cms_page
      |> Ecto.Changeset.change(%{discarded_at: now})
      |> Repo.update()

    from(v in CmsPageVersion, where: v.cms_page_id == ^cms_page.id)
    |> Repo.update_all(set: [discarded_at: now])

    Imagine.Cache.flush()

    result
  end

  def undelete_cms_page(%CmsPage{} = cms_page) do
    result =
      cms_page
      |> Ecto.Changeset.change(%{discarded_at: nil})
      |> Repo.update()

    from(v in CmsPageVersion, where: v.cms_page_id == ^cms_page.id)
    |> Repo.update_all(set: [discarded_at: nil])

    Imagine.Cache.flush()

    result
  end

  def destroy_cms_page(%CmsPage{} = cms_page) do
    result = Repo.delete(cms_page)

    Imagine.Cache.flush()

    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_page changes.

  ## Examples

      iex> change_cms_page(cms_page)
      %Ecto.Changeset{source: %CmsPage{}}

  """
  def change_cms_page(%CmsPage{} = cms_page) do
    Ecto.Changeset.change(cms_page)
  end

  @doc """
  Returns the list of cms_page_versions.

  ## Examples

      iex> list_cms_page_versions()
      [%CmsPageVersion{}, ...]

  """
  def list_cms_page_versions do
    Repo.all(active_versions_query())
  end

  @doc """
  Gets a single cms_page_version.

  Raises `Ecto.NoResultsError` if the Cms page version does not exist.

  ## Examples

      iex> get_cms_page_version!(123)
      %CmsPageVersion{}

      iex> get_cms_page_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page_version!(id),
    do: Repo.get!(active_versions_query(), id)

  @doc """
  Creates a cms_page_version.

  ## Examples

      iex> create_cms_page_version(%{field: value})
      {:ok, %CmsPageVersion{}}

      iex> create_cms_page_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page_version(cms_page) do
    %CmsPageVersion{}
    |> CmsPageVersion.changeset(cms_page)
    |> Repo.insert()
  end

  def delete_cms_page_version(cms_page_version) do
    object_query =
      from po in CmsPageObject, where: po.cms_page_version == ^cms_page_version.version

    {:ok, %{objects: _objects, version: version}} =
      Multi.new()
      |> Multi.delete_all(:objects, object_query)
      |> Multi.delete(:version, cms_page_version)
      |> Repo.transaction()

    {:ok, version}
  end

  @doc """
  Returns the list of cms_page_objects.

  ## Examples

      iex> list_cms_page_objects()
      [%CmsPageObject{}, ...]

  """
  def list_cms_page_objects do
    Repo.all(CmsPageObject)
  end

  @doc """
  Gets a single cms_page_object.

  Raises `Ecto.NoResultsError` if the Cms page object does not exist.

  ## Examples

      iex> get_cms_page_object!(123)
      %CmsPageObject{}

      iex> get_cms_page_object!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page_object!(id),
    do: Repo.get!(CmsPageObject, id)

  def build_cms_page_object(
        %CmsPage{id: cms_page_id, version: cms_page_version},
        obj_name,
        obj_type
      ) do
    build_cms_page_object(cms_page_id, cms_page_version, obj_name, obj_type)
  end

  def build_cms_page_object(
        %CmsPageVersion{cms_page_id: cms_page_id, version: cms_page_version},
        obj_name,
        obj_type
      ) do
    build_cms_page_object(cms_page_id, cms_page_version, obj_name, obj_type)
  end

  def build_cms_page_object(cms_page_id, cms_page_version, obj_name, obj_type) do
    %CmsPageObject{cms_page_id: cms_page_id}
    |> Ecto.Changeset.change(
      name: obj_name,
      obj_type: obj_type,
      cms_page_version: cms_page_version
    )
  end

  @doc """
  Creates a cms_page_object.

  ## Examples

      iex> create_cms_page_object(%{field: value})
      {:ok, %CmsPageObject{}}

      iex> create_cms_page_object(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page_object(cms_page, attrs \\ %{}) do
    cms_page
    |> Ecto.build_assoc(:objects)
    |> CmsPageObject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cms_page_object.

  ## Examples

      iex> update_cms_page_object(cms_page_object, %{field: new_value})
      {:ok, %CmsPageObject{}}

      iex> update_cms_page_object(cms_page_object, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_page_object(%CmsPageObject{} = cms_page_object, attrs) do
    cms_page_object
    |> CmsPageObject.changeset(attrs)
    |> Repo.update()
  end

  def clone_and_update_cms_page_object(%CmsPageObject{} = cms_page_object, attrs) do
    %CmsPageObject{}
    |> CmsPageObject.changeset(Map.from_struct(cms_page_object))
    |> CmsPageObject.changeset(attrs)
    |> Repo.insert()
  end

  def update_cms_page_objects([], [], _new_version) do
    # IO.puts("==== All page objects processed. ====")
  end

  def update_cms_page_objects(
        [cms_page_object | cms_page_objects],
        [attrs | attrses],
        new_version
      ) do
    # IO.puts("==== Processing page object #{inspect(cms_page_object)} -> #{inspect(attrs)} ====")

    {:ok, _} =
      clone_and_update_cms_page_object(
        cms_page_object,
        Map.put(attrs || %{}, "cms_page_version", new_version)
      )

    update_cms_page_objects(cms_page_objects, attrses, new_version)
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking cms_page_object changes.

  # ## Examples

  #     iex> change_cms_page_object(cms_page_object)
  #     %Ecto.Changeset{source: %CmsPageObject{}}

  # """
  # def change_cms_page_object(%CmsPageObject{} = cms_page_object) do
  #   CmsPageObject.changeset(cms_page_object, %{})
  # end

  @doc """
  Returns the list of cms_page_tags.

  ## Examples

      iex> list_cms_page_tags()
      [%CmsPageTag{}, ...]

  """
  def list_cms_page_tags do
    Repo.all(CmsPageTag)
  end

  @doc """
  Gets a single cms_page_tag.

  Raises `Ecto.NoResultsError` if the Cms page tag does not exist.

  ## Examples

      iex> get_cms_page_tag!(123)
      %CmsPageTag{}

      iex> get_cms_page_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page_tag!(id),
    do: Repo.get!(CmsPageTag, id)

  @doc """
  Creates a cms_page_tag.

  ## Examples

      iex> create_cms_page_tag(%{field: value})
      {:ok, %CmsPageTag{}}

      iex> create_cms_page_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page_tag(attrs) do
    %CmsPageTag{}
    |> CmsPageTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cms_page_tag.

  ## Examples

      iex> update_cms_page_tag(cms_page_tag, %{field: new_value})
      {:ok, %CmsPageTag{}}

      iex> update_cms_page_tag(cms_page_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_page_tag(%CmsPageTag{} = cms_page_tag, attrs) do
    cms_page_tag
    |> CmsPageTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CmsPageTag.

  ## Examples

      iex> delete_cms_page_tag(cms_page_tag)
      {:ok, %CmsPageTag{}}

      iex> delete_cms_page_tag(cms_page_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_page_tag(%CmsPageTag{} = cms_page_tag) do
    Repo.delete(cms_page_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_page_tag changes.

  ## Examples

      iex> change_cms_page_tag(cms_page_tag)
      %Ecto.Changeset{source: %CmsPageTag{}}

  """
  def change_cms_page_tag(%CmsPageTag{} = cms_page_tag) do
    CmsPageTag.changeset(cms_page_tag, %{})
  end
end
