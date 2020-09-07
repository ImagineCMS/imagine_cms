defmodule Imagine.CmsTemplates.CmsSnippet do
  @moduledoc """
  CmsSnippet - like templates, but used for smaller bits of code. Often used within templates.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Imagine.CmsTemplates.CmsTemplate

  schema "cms_snippets" do
    has_many :versions, Imagine.CmsTemplates.CmsSnippetVersion

    field :version, :integer

    field :name, :string
    field :description, :string
    field :content, :string
    field :content_eex, :string

    timestamps(inserted_at: :created_on, updated_at: :updated_on)
  end

  @doc false
  def changeset(cms_snippet, attrs) do
    content = attrs["content_eex"] || attrs[:content_eex] || cms_snippet.content_eex

    cms_snippet
    |> cast(attrs, [:name, :description])
    |> put_change(:version, (cms_snippet.version || 0) + 1)
    |> put_change(:content_eex, CmsTemplate.sanitize_content(content))
    |> validate_required([:name, :version])
  end
end
