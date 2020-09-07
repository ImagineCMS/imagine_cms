defmodule Imagine.CmsTemplates.RenderEditHelpers do
  @moduledoc """
  Defines CMS template helpers like text_editor in Edit mode (i.e. editor controls)
  """

  use Phoenix.HTML
  alias Imagine.CmsPages.CmsPageObject
  alias Imagine.CmsTemplates.RenderViewHelpers

  # add shortened, @conn-free versions of all the helpers to make templates look nicer
  defmacro text_editor(obj_name, opts \\ []) when is_binary(obj_name) do
    quote do
      text_editor(var!(assigns)[:conn], unquote(obj_name), unquote(opts))
    end
  end

  defmacro snippet(obj_name, opts \\ []) when is_binary(obj_name) do
    quote do
      snippet(var!(assigns)[:conn], unquote(obj_name), unquote(opts))
    end
  end

  defmacro page_list(obj_name, opts \\ []) when is_binary(obj_name) do
    quote do
      page_list(var!(assigns)[:conn], unquote(obj_name), unquote(opts))
    end
  end

  def text_editor(%Plug.Conn{assigns: %{cms_page: cms_page}}, obj_name, _opts) do
    new_obj = Imagine.CmsPages.build_cms_page_object(cms_page, obj_name, "text")

    # Imagine.CmsTemplates.RenderEditHelpers.text_editor(%Plug.Conn{adapter: {Plug.MissingAdapter},
    #  assigns: %{cms_page: %Imagine.CmsPages.CmsPage{}}, before_send: [], body_params: %Plug.Conn.Unfetched{aspect: :body_params}, cookies: %Plug.Conn.Unfetched{aspect: :cookies}, halted: false, host: "www.example.com", method: "GET", owner: nil, params: %Plug.Conn.Unfetched{aspect: :params}, path_info: [], path_params: %{}, port: 0, private: %{}, query_params: %Plug.Conn.Unfetched{aspect: :query_params}, query_string: "", remote_ip: nil, req_cookies: %Plug.Conn.Unfetched{aspect: :cookies}, req_headers: [], request_path: "", resp_body: nil, resp_cookies: %{}, resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"}], scheme: :http, script_name: [], secret_key_base: nil, state: :unset, status: nil}, "Content", [])
    obj =
      cms_page
      |> CmsPageObject.extract_page_objects_from_page()
      |> CmsPageObject.find_object(obj_name, "text")

    obj =
      case obj do
        nil -> Imagine.Repo.insert!(new_obj)
        _ -> obj
      end

    atom = String.to_atom("cms_page_objects[]")

    content_tag :div,
      id: "CmsPageObject-#{obj.id}-container",
      class: "Imagine-CmsPageObject-TextEditor" do
      [
        # content_tag(:div, raw(obj.content), id: "CmsPageObject-#{obj.id}"),
        textarea(atom, :content,
          value: raw(obj.content),
          name: "cms_page[objects][#{obj.id}][content]",
          id: "CmsPageObject-#{obj.id}",
          class: "rteditor"
        )
        # hidden_input(atom, :id, value: obj.id, name: "cms_page[objects][#{obj.id}][id]"),
        # hidden_input(atom, :cms_page_version,
        #   value: obj.cms_page_version,
        #   name: "cms_page[objects][#{obj.id}][cms_page_version]"
        # ),
        # hidden_input(atom, :name, value: obj.name, name: "cms_page[objects][#{obj.id}][name]"),
        # hidden_input(atom, :obj_type,
        #   value: obj.obj_type,
        #   name: "cms_page[objects][#{obj.id}][obj_type]"
        # ),
        # hidden_input(atom, :options,
        #   value: obj.options,
        #   name: "cms_page[objects][#{obj.id}][options]"
        # )
      ]
    end
  end

  # def text_editor(_conn, _, _) do
  #   "text_editor(): Invalid arguments provided. First argument should be @conn. Second argument should be a name."
  # end

  def snippet(conn, obj_name, opts) do
    RenderViewHelpers.snippet(conn, obj_name, opts)
  end

  def page_list(_conn, _obj_name, _opts) do
    "Page List modal not implemented yet (edit in template)"
  end

  def template_option(_opt_name, :string) do
    "template_option(opt_name, :string) not implemented yet"
  end

  def template_option(_opt_name, :checkbox) do
    "template_option(opt_name, :checkbox) not implemented yet"
  end

  #
  # older insert_object syntax
  #
  # defmacro insert_object(obj_name, type, opts \\ [])

  # defmacro insert_object(obj_name, :text, opts) do
  #   text_editor(obj_name, opts)
  # end

  # defmacro insert_object(obj_name, :snippet, opts) do
  #   snippet(obj_name, opts)
  # end

  # defmacro insert_object(obj_name, :page_list, opts) do
  #   page_list(obj_name, opts)
  # end

  def render(_conn, [partial: _partial_path] = _opts) do
    "render(partial: ...) not implemented yet"
  end
end
