defmodule Helpcenter.Repo.Migrations.AddKnowledgeBaseTables do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:tags, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :slug, :text

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:comments, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :content, :text, null: false

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :article_id, :uuid, null: false
    end

    create table(:categories, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :slug, :text
      add :description, :text

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:articles, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:comments) do
      modify :article_id,
             references(:articles,
               column: :id,
               name: "comments_article_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:articles) do
      add :title, :text, null: false
      add :slug, :text
      add :content, :text
      add :views_count, :bigint, default: 0
      add :published, :boolean, default: false

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :category_id,
          references(:categories,
            column: :id,
            name: "articles_category_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false
    end

    create table(:article_tags, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :article_id,
          references(:articles,
            column: :id,
            name: "article_tags_article_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :tag_id,
          references(:tags,
            column: :id,
            name: "article_tags_tag_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:article_tags, [:article_id, :tag_id],
             name: "article_tags_unique_article_tag_index"
           )

    create table(:article_feedbacks, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :helpful, :boolean, default: false
      add :feedback, :text

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :article_id,
          references(:articles,
            column: :id,
            name: "article_feedbacks_article_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false
    end
  end

  def down do
    drop constraint(:article_feedbacks, "article_feedbacks_article_id_fkey")

    drop table(:article_feedbacks)

    drop_if_exists unique_index(:article_tags, [:article_id, :tag_id],
                     name: "article_tags_unique_article_tag_index"
                   )

    drop constraint(:article_tags, "article_tags_article_id_fkey")

    drop constraint(:article_tags, "article_tags_tag_id_fkey")

    drop table(:article_tags)

    drop constraint(:articles, "articles_category_id_fkey")

    alter table(:articles) do
      remove :category_id
      remove :updated_at
      remove :inserted_at
      remove :published
      remove :views_count
      remove :content
      remove :slug
      remove :title
    end

    drop constraint(:comments, "comments_article_id_fkey")

    alter table(:comments) do
      modify :article_id, :uuid
    end

    drop table(:articles)

    drop table(:categories)

    drop table(:comments)

    drop table(:tags)
  end
end
