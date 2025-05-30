defmodule Helpcenter.KnowledgeBase.Article do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "articles"
    repo Helpcenter.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :slug, :string
    attribute :content, :string
    attribute :views_count, :integer, default: 0
    attribute :published, :boolean, default: false
    timestamps()
  end

  relationships do
    belongs_to :category, Helpcenter.KnowledgeBase.Category do
      source_attribute :category_id
      allow_nil? false
    end

    has_many :comments, Helpcenter.KnowledgeBase.Comment do
      destination_attribute :article_id
    end

    many_to_many :tags, Helpcenter.KnowledgeBase.Tag do
      through Helpcenter.KnowledgeBase.ArticleTag
      source_attribute_on_join_resource :article_id
      destination_attribute_on_join_resource :tag_id
    end

    has_many :article_feedbacks, Helpcenter.KnowledgeBase.ArticleFeedback do
      destination_attribute :article_id
    end
  end

  actions do
    default_accept [
      :title,
      :slug,
      :content,
      :views_count,
      :published,
      :category_id # added for category relationship
    ]
    defaults [:create, :read, :update, :destroy]

    create :create_with_category do
      description "Create an article and a category at the same time"
      argument :category_attrs, :map, allow_nil?: false
      change manage_relationship(:category_attrs, :category, type: :create)
    end

    update :add_comment do
      description "Add a comment to an article"
      require_atomic? false
      argument :comment, :map, allow_nil?: false
      change manage_relationship(:comment, :comments, type: :create)
    end

    update :add_feedback do
      description "Add a feedback to an article"
      require_atomic? false
      argument :feedback, :map, allow_nil?: false
      change manage_relationship(:feedback, :article_feedbacks, type: :create)
    end

    create :create_with_tags do
      description "Create an article with tags"
      argument :tags, {:array, :map}, allow_nil?: false
      change manage_relationship(:tags, :tags,
        on_no_match: :create,
        on_match: :ignore,
        on_missing: :create
      )
    end
  end
end
