defmodule Imagine.CmsPages.CmsPageTag do
  @moduledoc """
  CmsPageTag - simple string tags attached to pages
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_page_tags" do
    belongs_to :cms_page, Imagine.CmsPages.CmsPage

    field :name, :string

    timestamps(inserted_at: :created_on, updated_at: nil)
  end

  @doc false
  def changeset(cms_page_tag, attrs) do
    cms_page_tag
    |> cast(attrs, [:cms_page_id, :name])
    |> validate_required([:cms_page_id, :name])
  end
end
