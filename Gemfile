source "https://rubygems.org"

gemspec

gem "minitest", "~> 5.0"
gem "mutex_m"

gem "bcrypt"
gem "brakeman"
gem "puma"
gem "sqlite3"
gem "solid_cable"
gem "image_processing", "~> 2.0"
# ruby-vips is image_processing's :vips backend (the Rails 8 default variant
# processor). Without it, generating an Active Storage image variant/preview
# 500s even though libvips (the native lib) is installed — so demo avatars
# render as broken images. libvips ships in the demo Dockerfile.
gem "ruby-vips"
gem "paper_trail"
gem "factory_bot_rails"
gem "faker"
gem "rouge"

# PostHog instruments the live demo (test/dummy) only — product analytics,
# exception tracking, and Rails log forwarding. All PostHog code is confined to
# test/dummy and gated by test_mode (reports only in production); nothing ships
# in the gem.
gem "posthog-ruby", require: "posthog"
gem "posthog-rails"
# OpenTelemetry powers posthog-rails log forwarding; loaded lazily when logs
# are enabled, so require: false keeps them out of test/dev boot.
gem "opentelemetry-sdk", require: false
gem "opentelemetry-logs-sdk", ">= 0.6.0", require: false
gem "opentelemetry-exporter-otlp-logs", require: false

group :development do
  gem "rubocop-rails-omakase"
  gem "web-console"
  gem "hotwire-livereload"
  gem "better_errors"
  gem "binding_of_caller"
  gem "chrome_devtools_rails"
  # gem "i18n-debug"
end
