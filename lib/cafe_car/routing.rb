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

      super(*, **, concerns: [ :batchable, *concerns ], &)
    end
  end
end
