require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.hosts << ".ts.net"
  config.enable_reloading            = true
  config.eager_load                  = false
  config.consider_all_requests_local = true
  config.server_timing               = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching               = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store                = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store                       = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching       = false

  config.active_support.deprecation                     = :log
  config.active_support.disallowed_deprecation          = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.active_record.migration_error    = :page_load
  config.active_record.verbose_query_logs = true

  config.active_job.verbose_enqueue_logs = true

  config.action_view.annotate_rendered_view_with_filenames = false

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true
end
