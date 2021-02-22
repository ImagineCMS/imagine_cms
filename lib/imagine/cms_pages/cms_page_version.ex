defmodule Imagine.CmsPages.CmsPageVersion do
  @moduledoc """
  CmsPageVersion - a single version of CmsPage
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Imagine.Accounts.User
  alias Imagine.CmsPages.CmsPage
  alias Imagine.CmsTemplates.CmsTemplate

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
             :position
           ]}

  schema "cms_page_versions" do
    belongs_to :cms_page, CmsPage

    has_many :versions, through: [:cms_page, :versions]
    has_many :objects, through: [:cms_page, :objects]
    has_many :tags, through: [:cms_page, :tags]

    belongs_to :cms_template, CmsTemplate
    field :cms_template_version, :integer

    belongs_to :parent, CmsPage
    has_many :sub_pages, CmsPage, foreign_key: :parent_id, where: [discarded_at: nil]

    belongs_to :author, User, foreign_key: :updated_by
    field :updated_by_username, :string

    field :version, :integer

    field :path, :string
    field :name, :string
    field :title, :string

    field :layout, :string

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

    field :comment_count, :integer
    field :search_index, :string

    field :discarded_at, :naive_datetime

    timestamps(inserted_at: :created_on, updated_at: :updated_on)
  end

  @doc false
  def changeset(cms_page_version, %CmsPage{} = cms_page) do
    cms_page_version
    |> cast(Map.from_struct(cms_page), [
      :version,
      :cms_template_id,
      :cms_template_version,
      :parent_id,
      :path,
      :name,
      :title,
      :layout,
      :published_version,
      :published_date,
      :article_date,
      :article_end_date,
      :expiration_date,
      :expires,
      :summary,
      :html_head,
      :thumbnail_path,
      :feature_image_path,
      :redirect_enabled,
      :redirect_to,
      :position,
      :search_index,
      :updated_by,
      :updated_by_username
    ])
    |> put_change(:cms_page_id, cms_page.id)
    |> validate_required([:cms_page_id, :version, :title])
  end
end
