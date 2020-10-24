defmodule Imagine.CmsPages.CmsPageObject do
  @moduledoc """
  CmsPageObject - holds the actual content of CmsPage
  See the View and Edit render helpers to see how these are manipulated.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Imagine.CmsPages.CmsPage

  schema "cms_page_objects" do
    belongs_to :cms_page, CmsPage
    field :cms_page_version, :integer

    field :name, :string
    field :obj_type, :string

    field :content, :string
    field :options, :string

    timestamps(inserted_at: :created_on, updated_at: :updated_on)
  end

  @doc false
  def changeset(cms_page_object, attrs) do
    cms_page_object
    |> cast(attrs, [:cms_page_id, :cms_page_version, :name, :obj_type, :content, :options])
    |> validate_required([:cms_page_id, :cms_page_version, :name, :obj_type])
    |> extract_data_urls_into_files([:content])

    # |> clean_up_invalid_chars([:content])
  end

  def to_filename("", ""), do: "image"

  def to_filename("", data_filename) do
    ext = Path.extname(data_filename)
    Path.basename(data_filename, ext)
  end

  def to_filename(title, _) do
    String.replace(title, ~r/[^-_A-Za-z0-9]+/, "-")
  end

  def extract_data_urls_into_files(%{valid?: false} = changeset), do: changeset

  def extract_data_urls_into_files(changeset, fields) do
    cms_page_id = get_field(changeset, :cms_page_id)

    Enum.reduce(fields, changeset, fn f, changeset ->
      content =
        changeset
        |> get_field(f)
        |> replace_img_src_data_urls_with_files(cms_page_id)
        |> replace_a_href_data_urls_with_files(cms_page_id)

      put_change(changeset, f, content)
    end)
  end

  def replace_img_src_data_urls_with_files(html, cms_page_id) do
    html
    |> Floki.find("img")
    |> Enum.filter(&element_has_data_url(&1, "src"))
    |> Enum.map(&convert_data_url_to_image_file(&1, cms_page_id))
    |> Enum.reduce(html, fn {data_url, image_url}, html ->
      String.replace(html, data_url, image_url)
    end)
  end

  def replace_a_href_data_urls_with_files(html, cms_page_id) do
    html
    |> Floki.find("a")
    |> Enum.filter(&element_has_data_url(&1, "href"))
    |> Enum.map(&convert_data_url_to_file(&1, cms_page_id))
    |> Enum.reduce(html, fn {data_url, file_url}, html ->
      String.replace(html, data_url, file_url)
    end)
  end

  def element_has_data_url(element, attribute) do
    Enum.any?(Floki.attribute(element, attribute), &(&1 =~ ~r{^data:}))
  end

  def get_html_attribute(element, attr), do: element |> Floki.attribute(attr) |> List.first()

  def convert_data_url_to_image_file(img, cms_page_id) do
    with title <- get_html_attribute(img, "title") || "",
         data_filename <- get_html_attribute(img, "data-filename") || "",
         data_url <- get_html_attribute(img, "src"),
         tmp_path <- write_data_url_to_file(data_url, data_filename),
         filename <- to_filename(title, data_filename) <> Path.extname(tmp_path),
         {:ok, _new_or_existing, original_path, filename} <-
           CmsPage.store_original(filename, tmp_path),
         final_path <-
           CmsPage.link_original_to_page_path(original_path, filename, cms_page_id) do
      {data_url, final_path}
    end
  end

  def convert_data_url_to_file(a, cms_page_id) do
    with data_filename <- get_html_attribute(a, "data-filename") || "",
         data_url <- get_html_attribute(a, "href"),
         tmp_path <- write_data_url_to_file(data_url, data_filename),
         filename <- data_filename,
         {:ok, _new_or_existing, original_path, filename} <-
           CmsPage.store_original(filename, tmp_path),
         final_path <-
           CmsPage.link_original_to_page_path(original_path, filename, cms_page_id) do
      {data_url, final_path}
    end
  end

  def write_data_url_to_file(data_url, data_filename) do
    # mime_type = String.replace(data_url, ~r{^data:((?:image|application)/.+?);.*$}, "\\1")

    # determine extension by either removing leading "image/" or by specifying directly
    # extension =
    #   case mime_type do
    #     "image/jpeg" -> "jpg"
    #     "image/svg+xml" -> "svg"
    #     other -> String.replace(other, ~r/(application|image)\//, "")
    #   end

    extension = Path.extname(data_filename) |> String.downcase()

    data = String.replace(data_url, ~r{^data:(?:\w+)/(?:[-\w\.\+]+);base64,(.*)$}, "\\1")

    path =
      Path.join([System.tmp_dir!(), "image-#{System.unique_integer([:positive])}.#{extension}"])

    :ok = File.write!(path, Base.decode64!(data))

    path
  end

  # this doesn't seem to work as intended... :-(
  def clean_up_invalid_chars(changeset, fields) do
    for f <- fields do
      content =
        changeset
        |> get_field(f)
        |> strip_utf8

      put_change(changeset, f, content)
    end

    changeset
  end

  def strip_utf8(nil), do: nil
  def strip_utf8(str), do: for(<<c::utf8 <- str>>, into: "", do: <<c>>)

  def extract_page_objects_from_page(%{objects: objects}) do
    objects
  end

  def find_object([], _obj_name, _obj_type), do: nil

  def find_object([object | objects], obj_name, obj_type) do
    if object.name == obj_name && object.obj_type == obj_type do
      object
    else
      find_object(objects, obj_name, obj_type)
    end
  end
end
