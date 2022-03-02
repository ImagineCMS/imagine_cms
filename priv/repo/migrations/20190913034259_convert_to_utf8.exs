# also expands the thumbnail and feature image path fields
defmodule Imagine.Repo.Migrations.ConvertToUtf8 do
  use Ecto.Migration

  def up do
    target = "CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

    for tbl <- [
          "cms_templates",
          "cms_template_versions",
          "cms_snippets",
          "cms_snippet_versions",
          "cms_pages",
          "cms_page_versions",
          "cms_page_objects",
          "cms_page_tags",
          "users"
        ] do
      execute("ALTER TABLE #{tbl} CONVERT TO #{target}")
    end

    for {col, type} <- [
          name: "varchar(191)",
          description: "varchar(191)",
          content: "mediumtext",
          content_eex: "mediumtext",
          options_yaml: "mediumtext"
        ] do
      execute("ALTER TABLE cms_templates CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [
          name: "varchar(191)",
          description: "varchar(191)",
          content: "mediumtext",
          content_eex: "mediumtext",
          options_yaml: "mediumtext"
        ] do
      execute("ALTER TABLE cms_template_versions CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [
          name: "varchar(191)",
          description: "varchar(191)",
          content: "mediumtext",
          content_eex: "mediumtext"
        ] do
      execute("ALTER TABLE cms_snippets CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [
          name: "varchar(191)",
          description: "varchar(191)",
          content: "mediumtext",
          content_eex: "mediumtext"
        ] do
      execute("ALTER TABLE cms_snippet_versions CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [
          name: "varchar(191)",
          layout: "varchar(191)",
          path: "varchar(1024)",
          title: "varchar(1024)",
          summary: "mediumtext",
          html_head: "mediumtext",
          thumbnail_path: "varchar(1024)",
          feature_image_path: "varchar(1024)",
          redirect_to: "varchar(1024)",
          search_index: "mediumtext"
        ] do
      execute("ALTER TABLE cms_pages CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [
          name: "varchar(191)",
          layout: "varchar(191)",
          path: "varchar(1024)",
          title: "varchar(1024)",
          summary: "mediumtext",
          html_head: "mediumtext",
          thumbnail_path: "varchar(1024)",
          feature_image_path: "varchar(1024)",
          redirect_to: "varchar(1024)",
          search_index: "mediumtext"
        ] do
      execute("ALTER TABLE cms_page_versions CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [
          name: "varchar(191)",
          obj_type: "varchar(191)",
          content: "mediumtext",
          options: "mediumtext"
        ] do
      execute("ALTER TABLE cms_page_objects CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [name: "varchar(191)"] do
      execute("ALTER TABLE cms_page_tags CHANGE #{col} #{col} #{type} #{target}")
    end

    for {col, type} <- [
          username: "varchar(191)",
          email: "varchar(191)",
          password_hash: "varchar(191)",
          password_hash_type: "varchar(191)",
          first_name: "varchar(191)",
          last_name: "varchar(191)",
          dynamic_fields: "varchar(1024)"
        ] do
      execute("ALTER TABLE users CHANGE #{col} #{col} #{type} #{target}")
    end
  end

  # risk of data loss, do not roll back
  # def down do
  # end
end
