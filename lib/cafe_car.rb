require "cafe_car/core_ext"

require "cafe_car/version"
require "cafe_car/engine"
require "cafe_car/resolver"
require "cafe_car/proc_helpers"

module CafeCar
  include Resolver
  extend ProcHelpers

  class MissingAttributeError < StandardError
  end

  class AuthenticationFailed < StandardError
  end

  def self.use_relative_model_naming? = true

  # Name of the host application's user model. Hosts with a differently named
  # user model can override this (e.g. `CafeCar.user_class_name = "Account"`).
  mattr_accessor :user_class_name, default: "User"

  # Maximum number of rows a CSV export will emit. Bounds the memory/latency cost
  # of exporting a large table; truncated exports signal `X-CafeCar-Truncated`.
  mattr_accessor :csv_export_row_limit, default: 10_000

  # Upper bound on an index page's `?per=`. Clamps oversized requests so a caller
  # can't force the whole table into memory with `?per=1000000` (a DoS footgun);
  # the effective per-page is silently capped, not rejected.
  mattr_accessor :max_per_page, default: 200

  # Upper bound on the number of `<option>`s an association select loads. Bounds
  # the memory/latency cost of rendering a `belongs_to`/`has_many` field on every
  # form and filter sidebar; without it a 10k-row association loads the whole
  # table into memory each request. (A searchable/remote select is the fix for
  # associations larger than this — a separate follow-up.)
  mattr_accessor :max_collection_options, default: 100

  # Bundled themes selectable via `CafeCar.theme`. Each lives at
  # `app/assets/stylesheets/cafe_car/themes/<name>.css` as a set of CSS custom
  # properties layered over `themes/defaults.css`, with its own dark-mode block.
  THEMES = %i[warm cool cool2].freeze

  # The active bundled theme, injected as a <link> into every CafeCar page's
  # <head> (see `CafeCar::Helpers#theme_stylesheet_tag`). Defaults to `:warm` —
  # the theme the engine has always shipped — so an unset host renders unchanged.
  # Assigning a value outside THEMES raises rather than rendering unstyled.
  mattr_reader :theme, default: :warm

  def self.theme=(name)
    name = name&.to_sym
    unless THEMES.include?(name)
      raise ArgumentError,
        "unknown CafeCar theme #{name.inspect} (valid: #{THEMES.map(&:inspect).join(", ")})"
    end
    @@theme = name
  end

  # The host's user model, resolved lazily so the constant need not exist at
  # boot. Used by CafeCar::Session for authentication.
  def self.user_class = user_class_name.to_s.constantize

  # Whether the opt-in sessions/login infrastructure is available. True only
  # when the sessions table exists, so a CRUD-only host (no sessions migration)
  # degrades to 403 Forbidden instead of redirecting to a nonexistent login.
  def self.sessions_available?
    CafeCar[:Session].table_exists?
  rescue StandardError
    false
  end
end
