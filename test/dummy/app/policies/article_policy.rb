class ArticlePolicy < ApplicationPolicy
  def index?   = true
  def show?    = object.published? || edit?
  def create?  = true
  def update?  = true # object.author_id == user.id
  # Published articles are protected from deletion; drafts can be removed. Gives
  # bulk-delete a per-record authorization boundary to exercise.
  def destroy? = !object.published?
  # Only unpublished articles can be published — gives the custom `:publish` bulk
  # action a per-record authorization boundary (a published row is skipped).
  def publish? = !object.published?

  # Bulk actions offered on the articles index — the policy is the source of truth.
  # `:publish` is a host-defined action that "just works": a `publish?` predicate
  # here + a `publish!` method on the model, listed here. No registration anywhere.
  def permitted_bulk_actions = %i[publish destroy]

  def permitted_attributes
    [ :title, :author_id, :published_at, :summary, :body ]
  end

  # Dashboard metric tiles for articles: total count + published count. Drives the
  # `metrics Article` helper on the demo dashboard (opt-in, policy is source of truth).
  def permitted_metrics = %i[all published]

  # Named scopes URL filters may invoke (`?draft=true`). Scopes are opt-in —
  # see CafeCar::Policy#permitted_scopes — so `unpublished` (unlisted) stays
  # URL-unreachable, which the filtering tests assert.
  def permitted_scopes = %i[draft published]

  class Scope < Scope
    def resolve = scope.all
  end
end
