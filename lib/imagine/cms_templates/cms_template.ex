defmodule Imagine.CmsTemplates.CmsTemplate do
  @moduledoc """
  CMS Template (versioned)
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Imagine.CmsPages.CmsPage

  schema "cms_templates" do
    has_many :versions, Imagine.CmsTemplates.CmsTemplateVersion

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
  def changeset(cms_template, attrs) do
    content = attrs["content_eex"] || attrs[:content_eex] || cms_template.content_eex

    cms_template
    |> cast(attrs, [:name, :description, :options_json])
    |> put_change(:version, (cms_template.version || 0) + 1)
    |> put_change(:content_eex, content)
    |> validate_required([:name, :version])
  end

  def test_render(%Ecto.Changeset{} = changeset) do
    content = get_field(changeset, :content_eex)

    cms_page = %CmsPage{id: 1, objects: [], versions: []}
    test_conn = %Plug.Conn{}

    try do
      {:ok, render(:view, content, cms_page, test_conn)}
    rescue
      e in CompileError ->
        {:error, e}

      e in SyntaxError ->
        {:error, e}

      e in TokenMissingError ->
        {:error, e}

      e in EEx.SyntaxError ->
        {:error, Map.put(e, :description, e.message)}

      e in UndefinedFunctionError ->
        {:error, Map.merge(e, %{description: UndefinedFunctionError.message(e)})}

      e in Protocol.UndefinedError ->
        {:error, Map.merge(e, %{description: Protocol.UndefinedError.message(e)})}
    end
  end

  @render_helpers "use Phoenix.HTML; alias Imagine.{CmsPages, CmsPages.CmsPage}; import Kernel, only: [sigil_r: 2, sigil_s: 2, sigil_S: 2, if: 2, ==: 2, !=: 2, |>: 2, ||: 2, &&: 2];"
  def render(:view, content, cms_page, %Plug.Conn{} = conn) do
    header = "<% import Imagine.CmsTemplates.RenderViewHelpers; #{@render_helpers} %>"

    EEx.eval_string(
      header <> (content || ""),
      [assigns: [conn: Plug.Conn.assign(conn, :cms_page, cms_page), cms_page: cms_page]],
      engine: Phoenix.HTML.Engine
    )
  end

  # someday take a closer look at this:
  # https://elixirforum.com/t/using-code-eval-string-to-call-other-functions-in-the-module/12866/7
  def render(:edit, content, cms_page, %Plug.Conn{} = conn) do
    # keep this to one line (without a newline at the end) so that line numbers in error messages make sense
    header = "<% import Imagine.CmsTemplates.RenderEditHelpers; #{@render_helpers} %>"

    EEx.eval_string(
      header <> (content || ""),
      [assigns: [conn: Plug.Conn.assign(conn, :cms_page, cms_page), cms_page: cms_page]],
      engine: Phoenix.HTML.Engine
    )
  end

  # *very* rudimentary security measure to sanitize the worst (expected!) attack vectors
  def sanitize_content(nil), do: nil

  def sanitize_content(content) do
    # list all modules in this application
    {:ok, modules} = :application.get_key(:imagine_cms, :modules)

    # add on a few more dangerous ones
    modules =
      (modules ++
         [
           Agent,
           Application,
           Behaviour,
           Code,
           Config,
           Dict,
           DynamicSupervisor,
           EEx,
           Exunit,
           File,
           GenEvent,
           GenServer,
           HashDict,
           HashSet,
           IEx,
           IO,
           Macro,
           Mix,
           Node,
           Path,
           Port,
           Process,
           Registry,
           Set,
           Supervisor,
           System,
           Task,
           Ecto,
           Phoenix,
           Plug,
           :file
         ])
      |> Enum.map(&to_string/1)
      |> Enum.map(fn s -> String.replace(s, ~r/^Elixir\./, "") end)
      |> Enum.sort(fn a, b -> String.length(a) > String.length(b) end)

    content
    |> escape_modules(modules)
    |> escape_import_and_alias()
  end

  # deletes banned modules from template code
  defp escape_modules(content, []), do: content

  defp escape_modules(content, [module | modules]) do
    escape_modules(String.replace(content, ~r/(<%.*?)#{module}\.(.*?%>)/ms, "\\1\\2"), modules)
  end

  # deletes import and alias keywords, e.g. "import EEx", "alias Imagine.Repo"
  defp escape_import_and_alias(content) do
    String.replace(content, ~r/(<%.*?)(import|alias)([\(\s].*?%>)/ms, "\\1\\3")
  end
end
