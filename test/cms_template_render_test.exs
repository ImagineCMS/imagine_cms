defmodule Imagine.CmsTemplates.CmsTemplateTest do
  use ExUnit.Case, async: true

  alias Imagine.CmsPages.{CmsPage, CmsPageObject}
  alias Imagine.CmsTemplates.CmsTemplate

  test "dynamic CMS EEx rendering keeps legacy HTML helpers available" do
    cms_page = %CmsPage{
      id: 1,
      objects: [
        %CmsPageObject{name: "Body", obj_type: "text", content: "<strong>Hello</strong>"}
      ],
      versions: []
    }

    output =
      CmsTemplate.render(
        :view,
        """
        <%= content_tag :section, class: "legacy-helper" do %>
          <%= raw("<span>Raw</span>") %>
          <%= link "Docs", to: "/docs" %>
          <%= text_editor("Body") %>
        <% end %>
        """,
        cms_page,
        %Plug.Conn{}
      )

    html = Phoenix.HTML.safe_to_string(output)

    assert html =~ ~s(<section class="legacy-helper">)
    assert html =~ ~s(<span>Raw</span>)
    assert html =~ ~s(<a href="/docs">Docs</a>)
    assert html =~ ~s(<strong>Hello</strong>)
  end

  test "edit rendering uses HugeRTE inline region backed by hidden textarea" do
    cms_page = %CmsPage{
      id: 1,
      objects: [
        %CmsPageObject{id: 123, name: "Body", obj_type: "text", content: "<p>Editable</p>"}
      ],
      versions: []
    }

    output =
      CmsTemplate.render(
        :edit,
        ~S|<%= text_editor("Body") %>|,
        cms_page,
        %Plug.Conn{assigns: %{cms_page: cms_page}}
      )

    html = Phoenix.HTML.safe_to_string(output)

    assert html =~ ~s(name="cms_page[objects][123][content]")
    assert html =~ ~s(id="CmsPageObject-123")
    assert html =~ ~s(class="imagine-cms-rte-source")
    assert html =~ ~s(hidden)
    assert html =~ ~s(id="CmsPageObject-123-editor")
    assert html =~ ~s(class="imagine-cms-rte")
    assert html =~ ~s(contenteditable="true")
    assert html =~ ~s(data-textarea-id="CmsPageObject-123")
    assert html =~ "<p>Editable</p>"
  end
end
