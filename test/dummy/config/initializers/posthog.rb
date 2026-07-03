# frozen_string_literal: true

# PostHog instruments the live CafeCar demo (this test/dummy app) — product
# analytics, exception tracking, and Rails log forwarding.
#
# DEMO-ONLY + PRODUCTION-GUARDED. This whole file no-ops unless we're running
# the deployed demo (RAILS_ENV=production). The test suite and local dev must
# never init PostHog or make a network call, so everything below is wrapped in
# `if Rails.env.production?`. No PostHog code lives in the shipped gem.
if Rails.env.production?
  # Rails integration: capture exceptions (unhandled + rescued), instrument
  # ActiveJob, and forward Rails.logger output to PostHog Logs over OTLP.
  PostHog::Rails.configure do |config|
    config.auto_capture_exceptions = true
    config.report_rescued_exceptions = true
    config.auto_instrument_active_job = true

    # No HTTP current_user in this demo — auth here is websocket-only (see
    # app/channels), so there's no controller method to resolve. Leave user
    # context off rather than have the integration probe a missing method.
    config.capture_user_context = false

    # Forward Rails.logger into PostHog Logs, reusing the api_key/host below.
    config.logs_enabled = true
  end

  # Core client. The public ingestion token is a write-only key, safe to embed;
  # ENV override lets the deploy swap it without a code change.
  PostHog.init do |config|
    config.api_key = ENV.fetch("POSTHOG_API_KEY", "phc_nw2YF4GBQ9Df3bvE5WbTVenggYCbi3CT3EVjARWeEMHN")
    config.host = "https://us.i.posthog.com"
  end
end
