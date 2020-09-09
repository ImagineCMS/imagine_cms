defmodule Imagine.CmsTemplates do
  @moduledoc """
  The CmsTemplates context.
  """

  import Ecto.Query, warn: false
  alias Imagine.Repo

  alias Imagine.CmsTemplates.{CmsSnippet, CmsSnippetVersion, CmsTemplate, CmsTemplateVersion}

  @doc """
  Returns the list of cms_templates.

  ## Examples

      iex> list_cms_templates()
      [%CmsTemplate{}, ...]

  """
  def list_cms_templates do
    Repo.all(CmsTemplate |> order_by(:name))
  end

  @doc """
  Gets a single cms_template.

  Raises `Ecto.NoResultsError` if the Cms template does not exist.

  ## Examples

      iex> get_cms_template!(123)
      %CmsTemplate{}

      iex> get_cms_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_template!(id),
    do: Repo.get!(CmsTemplate, id)

  def get_cms_template_by(params),
    do: Repo.get_by(CmsTemplate, params)

  @doc """
  Creates a cms_template.

  ## Examples

      iex> create_cms_template(%{field: value})
      {:ok, %CmsTemplate{}}

      iex> create_cms_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_template(attrs) do
    result =
      %CmsTemplate{}
      |> CmsTemplate.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, cms_template} ->
        {:ok, _version} = create_cms_template_version(cms_template)
        result

      _ ->
        result
    end
  end

  @doc """
  Updates a cms_template.

  ## Examples

      iex> update_cms_template(cms_template, %{field: new_value})
      {:ok, %CmsTemplate{}}

      iex> update_cms_template(cms_template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_template(%CmsTemplate{} = cms_template, attrs) do
    changeset = CmsTemplate.changeset(cms_template, attrs)

    Imagine.Cache.flush()

    case CmsTemplate.test_render(changeset) do
      {:ok, _rendered_output} ->
        result = Repo.update(changeset)

        case result do
          {:ok, cms_template} ->
            {:ok, _version} = create_cms_template_version(cms_template)
            result

          _ ->
            result
        end

      {:error, err} ->
        {:error,
         Ecto.Changeset.add_error(
           changeset,
           :content_eex,
           "Could not compile template.",
           additional: "Line #{err.line || "?"}: #{err.description}"
         )}
    end
  end

  @doc """
  Deletes a CmsTemplate.

  ## Examples

      iex> delete_cms_template(cms_template)
      {:ok, %CmsTemplate{}}

      iex> delete_cms_template(cms_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_template(%CmsTemplate{} = cms_template) do
    result = Repo.delete(cms_template)

    Imagine.Cache.flush()

    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_template changes.

  ## Examples

      iex> change_cms_template(cms_template)
      %Ecto.Changeset{source: %CmsTemplate{}}

  """
  def change_cms_template(%CmsTemplate{} = cms_template) do
    CmsTemplate.changeset(cms_template, %{})
  end

  @doc """
  Returns the list of cms_template_versions.

  ## Examples

      iex> list_cms_template_versions()
      [%CmsSnippetVersion{}, ...]

  """
  def list_cms_template_versions do
    Repo.all(CmsTemplateVersion)
  end

  @doc """
  Gets a single cms_template_version.

  Raises `Ecto.NoResultsError` if the Cms template version does not exist.

  ## Examples

      iex> get_cms_template_version!(123)
      %CmsTemplateVersion{}

      iex> get_cms_template_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_template_version!(id),
    do: Repo.get!(CmsTemplateVersion, id)

  def get_cms_template_version_by(params),
    do: Repo.get_by(CmsTemplateVersion, params)

  @doc """
  Creates a cms_template_version.

  ## Examples

      iex> create_cms_template_version(%{field: value})
      {:ok, %CmsTemplateVersion{}}

      iex> create_cms_template_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_template_version(%CmsTemplate{} = cms_template) do
    %CmsTemplateVersion{}
    |> CmsTemplateVersion.changeset(cms_template)
    |> Repo.insert()
  end

  @doc """
  Returns the list of cms_snippets.

  ## Examples

      iex> list_cms_snippets()
      [%CmsSnippet{}, ...]

  """
  def list_cms_snippets do
    Repo.all(CmsSnippet |> order_by(:name))
  end

  @doc """
  Gets a single cms_snippet.

  Raises `Ecto.NoResultsError` if the Cms snippet does not exist.

  ## Examples

      iex> get_cms_snippet!(123)
      %CmsSnippet{}

      iex> get_cms_snippet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_snippet!(id),
    do: Repo.get!(CmsSnippet, id)

  def get_cms_snippet_by_name(name) do
    Repo.get_by(CmsSnippet, name: name)
  end

  @doc """
  Creates a cms_snippet.

  ## Examples

      iex> create_cms_snippet(%{field: value})
      {:ok, %CmsSnippet{}}

      iex> create_cms_snippet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_snippet(attrs) do
    result =
      %CmsSnippet{}
      |> CmsSnippet.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, cms_snippet} ->
        {:ok, _version} = create_cms_snippet_version(cms_snippet)
        result

      {:error, _} ->
        result
    end
  end

  @doc """
  Updates a cms_snippet.

  ## Examples

      iex> update_cms_snippet(cms_snippet, %{field: new_value})
      {:ok, %CmsSnippet{}}

      iex> update_cms_snippet(cms_snippet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_snippet(%CmsSnippet{} = cms_snippet, attrs) do
    result =
      cms_snippet
      |> CmsSnippet.changeset(attrs)
      |> Repo.update()

    Imagine.Cache.flush()

    case result do
      {:ok, cms_snippet} ->
        {:ok, _version} = create_cms_snippet_version(cms_snippet)
        result

      {:error, _} ->
        result
    end
  end

  @doc """
  Deletes a CmsSnippet.

  ## Examples

      iex> delete_cms_snippet(cms_snippet)
      {:ok, %CmsSnippet{}}

      iex> delete_cms_snippet(cms_snippet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_snippet(%CmsSnippet{} = cms_snippet) do
    result = Repo.delete(cms_snippet)

    Imagine.Cache.flush()

    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_snippet changes.

  ## Examples

      iex> change_cms_snippet(cms_snippet)
      %Ecto.Changeset{source: %CmsSnippet{}}

  """
  def change_cms_snippet(%CmsSnippet{} = cms_snippet) do
    CmsSnippet.changeset(cms_snippet, %{})
  end

  @doc """
  Returns the list of cms_snippet_versions.

  ## Examples

      iex> list_cms_snippet_versions()
      [%CmsSnippetVersion{}, ...]

  """
  def list_cms_snippet_versions do
    Repo.all(CmsSnippetVersion)
  end

  @doc """
  Gets a single cms_snippet_version.

  Raises `Ecto.NoResultsError` if the Cms snippet version does not exist.

  ## Examples

      iex> get_cms_snippet_version!(123)
      %CmsSnippetVersion{}

      iex> get_cms_snippet_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_snippet_version!(id),
    do: Repo.get!(CmsSnippetVersion, id)

  @doc """
  Creates a cms_snippet_version.

  ## Examples

      iex> create_cms_snippet_version(%{field: value})
      {:ok, %CmsSnippetVersion{}}

      iex> create_cms_snippet_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_snippet_version(%CmsSnippet{} = cms_snippet) do
    %CmsSnippetVersion{}
    |> CmsSnippetVersion.changeset(cms_snippet)
    |> Repo.insert()
  end
end
