namespace :demo do
  desc "Effect-level smoke check against the live demo (DEMO_URL to override the host)"
  task :smoke do
    script = File.expand_path("../../bin/demo-smoke", __dir__)
    # Deliberately standalone + on-demand — NOT part of the `default` (CI) task:
    # coupling repo CI to the external demo's uptime would make CI flaky.
    exit(1) unless system(RbConfig.ruby, script)
  end
end
