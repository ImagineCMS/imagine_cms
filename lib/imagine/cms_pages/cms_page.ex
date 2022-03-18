defmodule Imagine.CmsPages.CmsPage do
  @moduledoc """
  CMS Page (versioned, parent-child tree)
  has_many objects, tags, sub_pages
  belongs_to cms_template, parent
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Imagine.Repo

  alias Imagine.CmsPages
  alias Imagine.CmsPages.{CmsPage, CmsPageObject, CmsPageTag, CmsPageVersion}
  # alias Imagine.CmsTemplates
  alias Imagine.CmsTemplates.CmsTemplate

  alias Imagine.Accounts.User

  @derive {Jason.Encoder,
           only: [
             :version,
             :path,
             :name,
             :title,
             :published_date,
             :article_date,
             :article_end_date,
             :expiration_date,
             :summary,
             :thumbnail_path,
             :feature_image_path,
             :position,
             :index
           ]}

  schema "cms_pages" do
    has_many :versions, CmsPageVersion, on_delete: :delete_all
    has_many :objects, CmsPageObject
    has_many :tags, CmsPageTag

    belongs_to :cms_template, CmsTemplate
    field :cms_template_version, :integer

    belongs_to :parent, CmsPage
    has_many :sub_pages, CmsPage, foreign_key: :parent_id, where: [discarded_at: nil]

    belongs_to :author, User, foreign_key: :updated_by
    field :updated_by_username, :string

    field :layout, :string

    field :version, :integer

    field :path, :string
    field :name, :string
    field :title, :string

    field :published_version, :integer
    field :published_date, :naive_datetime
    field :article_date, :naive_datetime
    field :article_end_date, :naive_datetime
    field :expiration_date, :naive_datetime
    field :expires, :boolean, default: false

    field :summary, :string
    field :html_head, :string
    field :thumbnail_path, :string
    field :feature_image_path, :string

    field :redirect_enabled, :boolean, default: false
    field :redirect_to, :string

    field :position, :integer
    field :index, :integer, virtual: true

    # field :comment_count, :integer
    field :search_index, :string

    field :discarded_at, :naive_datetime

    timestamps(inserted_at: :created_on, updated_at: :updated_on)
  end

  def is_home_page?(cms_page) do
    cms_page.id && (cms_page.path == "" || cms_page.id == 1)
  end

  @doc false
  def changeset(
        cms_page,
        attrs,
        save_new_version \\ false,
        current_user \\ nil
      ) do
    cms_page
    |> cast(attrs, [
      :title,
      :name,
      :cms_template_id,
      :parent_id,
      :published_version,
      :expires,
      :summary,
      :html_head,
      :thumbnail_path,
      :feature_image_path,
      :redirect_enabled,
      :redirect_to,
      :position
    ])
    |> put_path
    |> put_date_with_default(:published_date, attrs)
    |> put_date_with_default(:article_date, attrs)
    |> put_date(:article_end_date, attrs)
    |> put_date(:expiration_date, attrs)
    |> put_change(:search_index, generate_search_index(cms_page))
    |> validate_required([
      :cms_template_id,
      :title,
      :published_date,
      :expires,
      :redirect_enabled,
      :position
    ])
    |> put_template_version
    |> validate_required([
      :cms_template_version
    ])
    |> put_version(cms_page, save_new_version)
    |> put_updated_by(current_user)
    |> validate_parent(cms_page.id)
    |> receive_file(attrs["thumbnail_file"], :thumbnail_path)
    |> receive_file(attrs["feature_image_file"], :feature_image_path)
  end

  def receive_file(changeset, nil, _attr), do: changeset

  def receive_file(changeset, upload, attr) do
    with cms_page_id <- get_field(changeset, :id),
         {:ok, _new_or_existing, original_path, filename} <- store_original(upload),
         final_path <- link_original_to_page_path(original_path, filename, cms_page_id) do
      put_change(changeset, attr, final_path)
    else
      {:error, _reason} = error -> error
    end
  end

  def store_original(%Plug.Upload{filename: filename, path: tmp_path}),
    do: store_original(filename, tmp_path)

  def store_original(filename, tmp_path) do
    with {:ok, %File.Stat{size: _size}} <- File.stat(tmp_path),
         hash <- hash_from_file(tmp_path, :sha256),
         original_path <-
           Path.join(["uploads", "originals"] ++ hashed_path(hash)),
         original_filepath <- Path.join(original_path, hash) do
      if File.exists?(original_filepath) do
        {:ok, :existing, original_filepath, filename}
      else
        File.mkdir_p!(original_path)
        File.cp!(tmp_path, original_filepath)
        {:ok, :new, original_filepath, filename}
      end
    else
      {:error, _reason} = error -> error
    end
  end

  def hashed_path(name, levels \\ 2) do
    name |> String.split("", trim: true) |> Enum.take(levels)
  end

  # TODO: in the event that the file is *not* new and a link pointing to the
  # target already exists, no need to increment the filename
  def link_original_to_page_path(original_path, filename, cms_page_id) do
    public_dir = Path.join(["public"])
    local_path = Path.join([public_dir, "assets", to_string(cms_page_id)])
    unique_filename = unique_filename_for_path(filename, local_path)
    final_filepath = Path.join(local_path, unique_filename)
    File.mkdir_p!(local_path)
    File.ln_s!(build_relative_path_to(original_path, from: local_path), final_filepath)
    "/" <> Path.relative_to(final_filepath, public_dir)
  end

  defp build_relative_path_to(path, from: cwd) do
    cwd_segments = Path.split(cwd)
    Path.join(Enum.map(cwd_segments, fn _ -> ".." end) ++ [path])
  end

  defp unique_filename_for_path(filename, path) do
    # FIXME: check to see whether file is identical before incrementing
    if File.exists?(Path.join(path, filename)),
      do: unique_filename_for_path(filename, path, 1),
      else: filename
  end

  defp unique_filename_for_path(filename, path, iteration) do
    extension = Path.extname(filename)
    basename = Path.basename(filename, extension)
    new_filename = "#{basename}-#{iteration}#{extension}"

    # FIXME: check to see whether file is identical before incrementing
    if File.exists?(Path.join(path, new_filename)),
      do: unique_filename_for_path(filename, path, iteration + 1),
      else: new_filename
  end

  def hash_from_file(path, algorithm, chunk_size \\ 2048) do
    path |> File.stream!([], chunk_size) |> hash_from_chunks(algorithm)
  end

  def hash_from_chunks(chunks_enum, algorithm) do
    chunks_enum
    |> Enum.reduce(:crypto.hash_init(algorithm), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  defp put_date(changeset, attr, attrs) when is_atom(attr) do
    val = attrs[Atom.to_string(attr)]

    if val,
      do: put_change(changeset, attr, format_date(val)),
      else: changeset
  end

  defp put_date_with_default(changeset, attr, attrs) when is_atom(attr) do
    val = attrs[Atom.to_string(attr)]

    if val,
      do: put_change(changeset, attr, format_date(val)),
      else: put_change(changeset, attr, NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second))
  end

  defp put_template_version(changeset) do
    case get_field(changeset, :cms_template_id) do
      nil ->
        changeset

      id ->
        cms_template = Imagine.CmsTemplates.get_cms_template!(id)
        put_change(changeset, :cms_template_version, cms_template.version)
    end
  end

  defp put_version(changeset, cms_page, false) do
    put_change(changeset, :version, cms_page.version || 0)
  end

  defp put_version(changeset, cms_page, true) do
    put_change(changeset, :version, (cms_page.version || 0) + 1)
  end

  defp put_updated_by(changeset, nil) do
    changeset
  end

  defp put_updated_by(changeset, %User{id: user_id, username: username}) do
    changeset
    |> put_change(:updated_by, user_id)
    |> put_change(:updated_by_username, username)
    |> validate_required([:updated_by, :updated_by_username])
  end

  defp put_updated_by(changeset, _current_user), do: changeset

  defp validate_parent(changeset, my_id),
    do: validate_parent(changeset, my_id, get_field(changeset, :parent_id))

  defp validate_parent(changeset, nil, _), do: changeset
  defp validate_parent(changeset, _, nil), do: changeset

  defp validate_parent(changeset, my_id, parent_id) when my_id == parent_id do
    add_error(
      changeset,
      :parent_id,
      "cannot be this page or one of its descendants (would create a cycle)"
    )
  end

  defp validate_parent(changeset, my_id, parent_id) do
    parent = CmsPages.get_cms_page(parent_id)

    case parent do
      nil -> changeset
      _ -> validate_parent(changeset, my_id, parent.parent_id)
    end
  end

  def get_all_parents(page, parents \\ []) do
    page = Imagine.Repo.preload(page, [:parent])

    if page.parent do
      get_all_parents(page.parent, [page.parent | parents])
    else
      parents
    end
  end

  def update_descendant_paths(nil), do: {:error, nil}

  def update_descendant_paths(cms_page) do
    update_descendant_paths(Imagine.Repo.preload(cms_page, :sub_pages).sub_pages, cms_page.path)
  end

  def update_descendant_paths([], _path), do: :ok

  def update_descendant_paths([cms_page | cms_pages], path) do
    new_path =
      [path, cms_page.name]
      |> Enum.reject(fn p -> p in [nil, ""] end)
      |> Enum.join("/")

    {:ok, updated_cms_page} =
      cms_page
      |> change(%{path: new_path})
      |> Imagine.Repo.update()

    new_id = updated_cms_page.id

    from(v in CmsPageVersion, where: v.cms_page_id == ^new_id)
    |> Repo.update_all(set: [path: updated_cms_page.path])

    Imagine.Repo.preload(updated_cms_page, :sub_pages).sub_pages
    |> update_descendant_paths(new_path)

    update_descendant_paths(cms_pages, path)
  end

  def format_date(nil), do: nil

  def format_date(str) do
    case Timex.parse(str, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end

  def put_path(changeset) do
    path = calculate_path(get_field(changeset, :parent_id), get_field(changeset, :name), [])

    put_change(changeset, :path, path)
  end

  def calculate_path(nil, name, path) do
    [name | path] |> Enum.reject(fn p -> p in [nil, ""] end) |> Enum.join("/")
  end

  def calculate_path(parent_id, name, path) do
    parent = CmsPages.get_cms_page!(parent_id)
    calculate_path(parent.parent_id, parent.name, [name | path])
  end

  def generate_search_index(cms_page) do
    # FIXME
    cms_page.name
  end
end
