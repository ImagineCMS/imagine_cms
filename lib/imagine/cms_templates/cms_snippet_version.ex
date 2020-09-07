defmodule Imagine.CmsTemplates.CmsSnippetVersion do
  @moduledoc """
  CmsSnippetVersion - a single version of CmsSnippet
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_snippet_versions" do
    belongs_to :cms_snippet, Imagine.CmsTemplates.CmsSnippet

    field :version, :integer

    field :name, :string
    field :description, :string
    field :content, :string
    field :content_eex, :string

    timestamps(inserted_at: :created_on, updated_at: :updated_on)
  end

  @doc false
  def changeset(cms_snippet_version, cms_snippet) do
    cms_snippet_version
    |> cast(Map.from_struct(cms_snippet), [
      :name,
      :description,
      :content,
      :content_eex,
      :version
    ])
    |> put_change(:cms_snippet_id, cms_snippet.id)
    |> validate_required([:name, :version, :cms_snippet_id])
  end
end
