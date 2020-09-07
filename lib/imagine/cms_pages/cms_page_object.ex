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

  def write_data_url_to_file(data_url) do
    mime_type = String.replace(data_url, ~r{^data:(image/.+?);.*$}, "\\1")

    # determine extension by either removing leading "image/" or by specifying directly
    extension =
      %{
        "image/jpeg" => "jpg",
        "image/svg+xml" => "svg"
      }[mime_type] || String.replace(mime_type, "image/", "")

    data = String.replace(data_url, ~r{^data:image/(\w+);base64,(.*)$}, "\\2")

    path =
      Path.join([System.tmp_dir!(), "image-#{System.unique_integer([:positive])}.#{extension}"])

    File.write!(path, Base.decode64!(data))
    path
  end

  # this doesn't seem to work as intended... :-(
  def clean_up_invalid_chars(changeset, fields) do
    for f <- fields do
      content =
        changeset
        |> get_field(f)
        |> IO.inspect(label: "#{f} before strip_utf8")
        # IO.inspect(String.valid?(content), "String.valid?(#{f})")
        # content = content
        |> strip_utf8
        |> IO.inspect(label: "#{f} after strip_utf8")

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
