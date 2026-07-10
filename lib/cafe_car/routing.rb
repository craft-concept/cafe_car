module CafeCar
  module Routing
    extend ActiveSupport::Concern

    def resources(*, concerns: [], **, &)
      @concerns[:batchable] || begin
        concern :batchable do
          collection do
            post :batch
          end
        end
      end

      # JSON typeahead feed for searchable association selects (Tom Select).
      # `GET /<resources>/options?q=` returns policy-scoped [{value, text}] pairs,
      # letting an association field reach records past `max_collection_options`.
      @concerns[:searchable] || begin
        concern :searchable do
          collection do
            get :options
          end
        end
      end

      # Policy-declared custom actions (Policy#permitted_member_actions /
      # #permitted_collection_actions) route through one generic endpoint each —
      # the action name is a URL param, so a host never enumerates them here.
      # POST /<resources>/:id/actions/:member_action → Controller#member_action
      # POST /<resources>/actions/:collection_action → Controller#collection_action
      # The policy whitelists which names resolve; anything else is a 404.
      @concerns[:actionable] || begin
        concern :actionable do
          member     { post "actions/:member_action",     action: :member_action,     as: :member_action }
          collection { post "actions/:collection_action", action: :collection_action, as: :collection_action }
        end
      end

      super(*, **, concerns: [ :batchable, :searchable, :actionable, *concerns ], &)
    end
  end
end
