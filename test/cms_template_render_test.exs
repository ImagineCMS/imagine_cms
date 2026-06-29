defmodule Imagine.CmsTemplates.CmsTemplateTest do
  use ExUnit.Case, async: true

  alias Imagine.CmsPages.{CmsPage, CmsPageObject}
  alias Imagine.CmsTemplates.Handlebars
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

  test "page-list handlebars interpolation renders escaped CMS page fields" do
    cms_page = %CmsPage{
      path: "stories/a-better-place",
      title: ~s(A <Better> "Place"),
      thumbnail_path: "/assets/1/thumb.jpg"
    }

    output =
      Handlebars.render(
        ~s(<a href="/{{path}}" data-src="{{thumbnail_path}}">{{title}}</a>),
        cms_page
      )

    assert output ==
             ~s(<a href="/stories/a-better-place" data-src="/assets/1/thumb.jpg">A &lt;Better&gt; &quot;Place&quot;</a>)
  end

  test "page-list handlebars interpolation supports raw and missing values" do
    output =
      Handlebars.render(
        ~s({{{html}}} {{missing}} {{nested.title}} {{this.name}}),
        %{
          html: "<strong>Raw</strong>",
          nested: %{title: "Nested"},
          name: "Current"
        }
      )

    assert output == "<strong>Raw</strong>  Nested Current"
  end
end
