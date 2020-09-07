defmodule Imagine.CmsTemplates.CmsTemplateVersion do
  @moduledoc """
  CmsTemplateVersion - a single version of CmsTemplate
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Imagine.CmsTemplates.CmsTemplate

  schema "cms_template_versions" do
    belongs_to :cms_template, CmsTemplate

    field :version, :integer

    field :name, :string
    field :description, :string

    # new fields
    field :content_eex, :string
    field :options_json, :string

    # legacy fields (deprecated, but retained so that 5 and 6 can operate side-by-side on the same db)
    field :content, :string
    field :options_yaml, :string

    timestamps(inserted_at: :created_on, updated_at: :updated_on)
  end

  @doc false
  def changeset(cms_template_version, %CmsTemplate{} = cms_template) do
    cms_template_version
    |> cast(Map.from_struct(cms_template), [
      :name,
      :description,
      :content,
      :content_eex,
      :options_yaml,
      :options_json,
      :version
    ])
    |> put_change(:cms_template_id, cms_template.id)
    |> validate_required([:name, :version, :cms_template_id])
  end
end
