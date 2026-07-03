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

  # TEMPORARY diagnostic — remove once error-tracking is verified on the demo.
  # A gated route that raises a controlled 500 so we can confirm captured
  # exceptions carry $current_url, request params, and a $session_id/distinct_id
  # in PostHog. Safe: it only raises a benign StandardError, and it 404s unless
  # the probe token is supplied, so bots and visitors never trip it.
  #   Trigger: GET /__posthog_boom__?token=posthog-probe&probe=hello
  Rails.application.routes.append do
    get "/__posthog_boom__", to: lambda { |env|
      if Rack::Request.new(env).params["token"] == "posthog-probe"
        raise "PostHog demo probe: intentional test error (safe to ignore)"
      end

      [ 404, { "content-type" => "text/plain" }, [ "Not found" ] ]
    }
  end
end
