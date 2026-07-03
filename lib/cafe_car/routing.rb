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

      super(*, **, concerns: [ :batchable, :searchable, *concerns ], &)
    end
  end
end
