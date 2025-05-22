defmodule Helpcenter.KnowledgeBase.Category do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "categories"
    repo Helpcenter.Repo
    references do
      reference :articles, on_delete: :delete
    end
  end

  pub_sub do
    module HelpcenterWeb.Endpoint

    prefix "categories"

    publish_all :update, [[:id, nil]]
    publish_all :create, [[:id, nil]]
    publish_all :destroy, [[:id, nil]]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :slug, :string
    attribute :description, :string, allow_nil?: true
    timestamps()
  end

  relationships do
    has_many :articles, Helpcenter.KnowledgeBase.Article do
      description "Relationship with the articles."
      destination_attribute :category_id
    end

    aggregates do
      count :article_count, :articles
    end
  end

  actions do
    default_accept [:name, :slug, :description]
    defaults [:create, :read, :update, :destroy]

    update :create_article do
      description "Create an an article under a specified category"
      require_atomic? false
      argument :article_attrs, :map, allow_nil?: false
      change manage_relationship(:article_attrs, :articles, type: :create)
    end

    create :create_with_article do
      description "Create a category and an article at the same time"
      argument :article_attrs, :map, allow_nil?: false
      change manage_relationship(:article_attrs, :articles, type: :create)
    end
  end
end
