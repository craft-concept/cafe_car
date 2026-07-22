module CafeCar
  module Routing
    # The endpoints `cafe_car` draws beyond Rails' RESTful seven. Each is an
    # action name, so `only:`/`except:` filter them like any other action.
    ENDPOINTS = %i[batch options member_action collection_action].freeze

    # `cafe_car :articles` — `resources :articles` plus CafeCar's endpoints:
    #
    #   POST /articles/batch                       — bulk actions (Controller#batch)
    #   GET  /articles/options?q=                  — typeahead JSON feed for
    #                                                searchable association selects
    #   POST /articles/:id/actions/:member_action  — policy-declared member action
    #   POST /articles/actions/:collection_action  — policy-declared collection action
    #
    # The custom-action endpoints are generic: the action name is a URL param, so
    # a host never enumerates them here — the policy's `permitted_member_actions`
    # / `permitted_collection_actions` whitelist which names resolve; anything
    # else is a 404.
    #
    # A plain `resources` call is untouched: a host resource gets CafeCar routes
    # only by asking for them here. `only:`/`except:` narrow the CafeCar
    # endpoints along with the RESTful ones — a read-only resource
    # (`cafe_car :articles, only: %i[index show]`) draws no mutating routes at
    # all. Other options and a block pass through to `resources` verbatim.
    def cafe_car(*names, **options, &block)
      only, except = options.values_at(:only, :except).map { Array(_1).map(&:to_sym) if _1 }

      endpoints  = ENDPOINTS
      endpoints &= only   if only
      endpoints -= except if except

      # Rails validates `only:`/`except:` against the RESTful seven, so
      # CafeCar's endpoint names come out before delegating.
      options[:only]   = only   - ENDPOINTS if only
      options[:except] = except - ENDPOINTS if except

      resources(*names, **options) do
        collection do
          post :batch   if endpoints.include?(:batch)
          get  :options if endpoints.include?(:options)
          if endpoints.include?(:collection_action)
            post "actions/:collection_action", action: :collection_action, as: :collection_action
          end
        end

        member do
          if endpoints.include?(:member_action)
            post "actions/:member_action", action: :member_action, as: :member_action
          end
        end

        yield if block
      end
    end
  end
end
