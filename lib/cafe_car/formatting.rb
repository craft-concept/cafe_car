module CafeCar
  # The safe, standalone subset of CafeCar's view helpers — value formatting
  # through the presenters — that a host app can expose app-wide
  # (`helper CafeCar::Formatting`) WITHOUT the admin-only overrides in
  # CafeCar::Helpers. Those overrides (link_to, capture, the `p` alias, and the
  # Capitalized `method_missing` → `ui` routing) are load-bearing inside
  # CafeCar's own views but have heavy blast radius in a host app, so they stay
  # out of this module.
  module Formatting
    # Format `value` with CafeCar's presenters — `present(amount, as: :currency)`,
    # `present(date, as: :date)`, `present(record)`. Memoized per view render.
    # The same entry point CafeCar's own views use, offered on its own so a host
    # can format values without adopting the admin helper set. The scalar path
    # (`as: :currency/:date/...`) renders through Rails' own number/date helpers —
    # no admin CSS or partials.
    def present(*args, **options)
      @presenters                    ||= {}
      @presenters[[ args, options ]] ||= CafeCar[:Presenter].present(self, *args, **options)
    end
  end
end
