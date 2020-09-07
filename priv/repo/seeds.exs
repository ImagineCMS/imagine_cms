# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

#
# In production, set PORT to something random when running to avoid a conflict
#

alias Imagine.Accounts
alias Imagine.CmsTemplates
alias Imagine.CmsPages

attrs = %{
  username: "demo",
  password: "Jh*UeD92Qtzc-dcmGZopPLTX",
  email: "demo@example.com",
  active: true
}

user =
  case Accounts.get_user_by_username_or_email("demo") do
    nil ->
      {:ok, new_user} = Accounts.create_user(attrs)
      Accounts.update_user_set_is_superuser(new_user, true)
      new_user

    existing_user ->
      existing_user
  end

attrs = %{
  name: "Home",
  description: "For the home page only",
  content: "<%= text_editor(\"Content\") %>"
}

tpl =
  case CmsTemplates.get_cms_template_by(name: "Home") do
    nil ->
      {:ok, tpl} = CmsTemplates.create_cms_template(attrs)
      tpl

    existing_template ->
      existing_template
  end

attrs = %{
  name: "",
  path: "",
  title: "Home",
  cms_template_id: tpl.id,
  cms_template_version: tpl.version,
  position: 0,
  published_version: 0
}

_home_page =
  case CmsPages.get_cms_page_by_path("") do
    nil ->
      {:ok, page} = CmsPages.create_cms_page(attrs, user)
      page

    existing_page ->
      existing_page
  end
