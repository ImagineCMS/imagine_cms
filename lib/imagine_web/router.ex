defmodule ImagineWeb.Router do
  use ImagineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :put_root_layout, {ImagineWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ImagineWeb.Plugs.Auth
  end

  pipeline :manage do
    plug ImagineWeb.Plugs.SetManageRootLayout
    plug ImagineWeb.Plugs.EnsureUser
  end

  pipeline :cms do
    plug :put_layout, {ImagineWeb.LayoutView, :app}
  end

  scope "/manage", ImagineWeb do
    pipe_through [:browser, :manage]

    get "/", CmsController, :index

    get "/cms_pages/:id/edit_content", CmsPageController, :edit_content
    post "/cms_pages/:id/update_content", CmsPageController, :update_content

    post "/cms_pages/:id/set_published_version/:version",
         CmsPageController,
         :set_published_version

    post "/cms_pages/:id/undelete", CmsPageController, :undelete
    delete "/cms_pages/:id/destroy", CmsPageController, :destroy

    resources "/cms_pages", CmsPageController do
      resources "/versions", CmsPageVersionController, as: :version
    end

    resources "/cms_snippets", CmsSnippetController do
      resources "/versions", CmsSnippetVersionController, as: :version
    end

    resources "/cms_templates", CmsTemplateController do
      resources "/versions", CmsTemplateVersionController, as: :version
    end

    get "/account/edit", AccountController, :edit
    post "/account/update", AccountController, :update

    post "/users/:id/disable", UserController, :disable
    post "/users/:id/enable", UserController, :enable
    resources "/users", UserController
  end

  scope "/", ImagineWeb do
    pipe_through [:browser, :manage]

    get "/manage/login", AuthController, :login
    post "/manage/login", AuthController, :handle_login
    delete "/manage/logout", AuthController, :handle_logout
  end

  scope "/", ImagineWeb do
    pipe_through [:browser, :cms]

    get "/*path", CmsRendererController, :show
  end
end
