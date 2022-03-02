# use this migration (fresh db) or the imagine_5_to_6 + utf8 migrations (conversion), but not both
defmodule Imagine.Repo.Migrations.CmsTables do
  use Ecto.Migration

  def up do
    create_if_not_exists(table(:cms_templates)) do
      add(:version, :integer, default: 0, null: false)

      add(:name, :string, size: 191)
      add(:content, :text, size: 16_777_215)
      add(:content_eex, :text, size: 16_777_215)
      add(:description, :string, size: 191)

      add(:options_yaml, :text, size: 16_777_215)
      add(:options_json, :text, size: 16_777_215)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists(table(:cms_template_versions)) do
      add(:cms_template_id, :integer)
      add(:version, :integer)

      add(:name, :string, size: 191)
      add(:content, :text, size: 16_777_215)
      add(:content_eex, :text, size: 16_777_215)
      add(:description, :string, size: 191)

      add(:options_yaml, :text, size: 16_777_215)
      add(:options_json, :text, size: 16_777_215)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists(table(:cms_snippets)) do
      add(:version, :integer, default: 0, null: false)

      add(:name, :string, size: 191)
      add(:content, :text, size: 16_777_215)
      add(:content_eex, :text, size: 16_777_215)
      add(:description, :string, size: 191)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists(table(:cms_snippet_versions)) do
      add(:cms_snippet_id, :integer)
      add(:version, :integer)

      add(:name, :string, size: 191)
      add(:content, :text, size: 16_777_215)
      add(:content_eex, :text, size: 16_777_215)
      add(:description, :string, size: 191)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists table(:cms_pages) do
      add(:version, :integer, default: 0, null: false)
      add(:cms_template_id, :integer, null: false)
      add(:cms_template_version, :integer, null: false)

      add(:parent_id, :integer)
      add(:path, :text, size: 16_777_215)
      add(:name, :string, size: 191)
      add(:title, :string, size: 191)
      add(:layout, :string, size: 191)

      add(:published_version, :integer, default: 0, null: false)
      add(:published_date, :naive_datetime, null: false)
      add(:article_date, :naive_datetime)
      add(:article_end_date, :naive_datetime)
      add(:expiration_date, :naive_datetime)
      add(:expires, :boolean, default: false, null: false)

      add(:summary, :text, size: 16_777_215)
      add(:html_head, :text, size: 16_777_215)
      add(:thumbnail_path, :string, size: 191)
      add(:feature_image_path, :string, size: 191)

      add(:redirect_enabled, :boolean, default: false, null: false)
      add(:redirect_to, :text, size: 16_777_215)

      add(:position, :integer, default: 0)

      add(:comment_count, :integer, default: 0)
      add(:search_index, :text, size: 16_777_215)

      add(:updated_by, :integer, null: false)
      add(:updated_by_username, :string, size: 191, null: false)

      add(:discarded_at, :naive_datetime)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists table(:cms_page_versions) do
      add(:cms_page_id, :integer, null: false)
      add(:version, :integer, default: 0, null: false)
      add(:cms_template_id, :integer, null: false)
      add(:cms_template_version, :integer, null: false)

      add(:parent_id, :integer)
      add(:path, :text, size: 16_777_215)
      add(:name, :string, size: 191)
      add(:title, :string, size: 191)
      add(:layout, :string, size: 191)

      add(:published_version, :integer, default: 0, null: false)
      add(:published_date, :naive_datetime, null: false)
      add(:article_date, :naive_datetime)
      add(:article_end_date, :naive_datetime)
      add(:expiration_date, :naive_datetime)
      add(:expires, :boolean, default: false, null: false)

      add(:summary, :text, size: 16_777_215)
      add(:html_head, :text, size: 16_777_215)
      add(:thumbnail_path, :string, size: 191)
      add(:feature_image_path, :string, size: 191)

      add(:redirect_enabled, :boolean, default: false, null: false)
      add(:redirect_to, :text, size: 16_777_215)

      add(:position, :integer, default: 0)

      add(:comment_count, :integer, default: 0)
      add(:search_index, :text, size: 16_777_215)

      add(:updated_by, :integer, null: false)
      add(:updated_by_username, :string, size: 191, null: false)

      add(:discarded_at, :naive_datetime)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists table(:cms_page_objects) do
      add(:cms_page_id, :integer, null: false)
      add(:cms_page_version, :integer, null: false)

      add(:name, :string, size: 191)
      add(:obj_type, :string, size: 191)
      add(:content, :text, size: 16_777_215)
      add(:options, :text, size: 16_777_215)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists table(:cms_page_tags) do
      add(:cms_page_id, :integer, null: false)
      add(:name, :string, size: 191, null: false)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create_if_not_exists table(:users) do
      add(:username, :string, size: 191)
      add(:email, :string, size: 191)
      add(:password_hash, :string, size: 191)
      add(:password_hash_type, :string, size: 191)

      add(:first_name, :string, size: 191)
      add(:last_name, :string, size: 191)

      add(:dynamic_fields, :text, size: 16_777_215)

      add(:active, :boolean, default: true, null: false)
      add(:is_superuser, :boolean, default: false, null: false)

      timestamps(inserted_at: :created_on, updated_at: :updated_on)
    end

    create(index("cms_pages", ["path(255)"]))
    create(index("cms_page_versions", ["path(255)"]))
    create(index("cms_page_objects", [:cms_page_id, :cms_page_version]))
    create(index("cms_page_tags", [:cms_page_id]))
    create(index("cms_page_versions", [:cms_page_id]))
    create(index("cms_snippets", [:name]))
    create(index("cms_snippet_versions", [:cms_snippet_id]))
    create(index("cms_template_versions", [:cms_template_id]))
  end

  # risk of data loss, do not roll back
  # def down do
  # end
end
