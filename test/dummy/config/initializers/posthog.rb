# frozen_string_literal: true

# PostHog instruments the live CafeCar demo (this test/dummy app) — product
# analytics, exception tracking, and Rails log forwarding.
#
# This file is NOT production-guarded: the dummy app isn't shipped with the gem,
# and running the PostHog code path in every environment is how we catch a
# breakage (a bad option, a renamed hook) in dev/test instead of in production.
# Reporting is gated by `config.test_mode` below, not by wrapping the wiring in
# `if Rails.env.production?`: outside production the core client swaps in a
# NoopWorker (no network) and the Logs pipeline follows the same test_mode flag,
# so the code runs but nothing ships. No PostHog code lives in the shipped gem.

# Rails integration: capture exceptions (unhandled + rescued), instrument
# ActiveJob, and forward Rails.logger output to PostHog Logs over OTLP.
PostHog::Rails.configure do |config|
  config.auto_capture_exceptions = true
  config.report_rescued_exceptions = true
  config.auto_instrument_active_job = true

  # Identify captured events/exceptions with the logged-in user. posthog-rails
  # resolves `current_user` on the controller (CafeCar's Authentication concern
  # provides it) and uses the user's `id` as the distinct id — the same id the
  # posthog-js `identify` call sends from the browser (see layouts/_posthog).
  config.capture_user_context = true

  # Forward Rails.logger into PostHog Logs, reusing the api_key/host below. The
  # Logs pipeline respects the core client's test_mode, so it stays off in
  # dev/test alongside the events client — no separate env guard needed.
  config.logs_enabled = true
end

# Core client. The public ingestion token is a write-only key, safe to embed;
# ENV override lets the deploy swap it without a code change.
PostHog.init do |config|
  config.api_key = ENV.fetch("POSTHOG_API_KEY", "phc_nw2YF4GBQ9Df3bvE5WbTVenggYCbi3CT3EVjARWeEMHN")
  config.host = "https://us.i.posthog.com"

  # Report only from the deployed demo. Everywhere else the client swaps in a
  # NoopWorker, so the wiring is exercised (dev/test) without emitting a single
  # network call — the test suite must never touch posthog.com.
  config.test_mode = !Rails.env.production?

  # Deduplicate web-request exceptions. On Rails 8.1, ActionDispatch::ShowExceptions
  # rescues and renders the error page, and the *outer* ActionDispatch::Executor
  # (which sits above PostHog's CaptureExceptions/RequestContext middleware) reports
  # the exception to Rails.error AFTER our middleware has unwound. By then
  # in_web_request? is false and no request context is active, so posthog-rails'
  # ErrorSubscriber emits a second, bare $exception (source
  # "application.action_dispatch") with no $current_url, params, or $session_id —
  # while CaptureExceptions already captured the rich, session-linked copy
  # (source "rails"). Drop the bare Executor duplicate so each web-request error
  # is exactly one replay-linkable event.
  config.before_send = lambda do |event|
    duplicate = event[:event] == "$exception" &&
      event.dig(:properties, "$exception_source") == "application.action_dispatch"
    duplicate ? nil : event
  end
end
