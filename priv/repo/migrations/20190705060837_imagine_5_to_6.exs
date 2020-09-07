defmodule Imagine.Repo.Migrations.Imagine5to6 do
  use Ecto.Migration

  # use either this migration or the cms_tables migration, but not both
  # note that some legacy dbs may already have the html_head column and/or the user email column
  def up do
    alter table(:cms_pages) do
      add(:layout, :string, size: 191)
      add(:html_head, :text, size: 16_777_215)
      add(:discarded_at, :naive_datetime)
    end

    alter table(:cms_page_versions) do
      add(:layout, :string)
      add(:html_head, :text, size: 16_777_215)
      add(:discarded_at, :naive_datetime)
    end

    alter table(:cms_templates) do
      add(:description, :string, size: 191)
      add(:content_eex, :text, size: 16_777_215)
      add(:options_json, :text, size: 16_777_215)
    end

    alter table(:cms_template_versions) do
      add(:description, :string, size: 191)
      add(:content_eex, :text, size: 16_777_215)
      add(:options_json, :text, size: 16_777_215)
    end

    alter table(:cms_snippets) do
      add(:description, :string, size: 191)
      add(:content_eex, :text, size: 16_777_215)
    end

    alter table(:cms_snippet_versions) do
      add(:description, :string, size: 191)
      add(:content_eex, :text, size: 16_777_215)
    end

    alter table(:users) do
      add(:email, :string, size: 191)
      add(:password_hash_type, :string)
    end
  end

  # risk of data loss, do not roll back
  # def down do
  # end
end
