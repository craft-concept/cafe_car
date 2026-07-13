require "bundler/setup"
require "bundler/gem_tasks"
require "rubocop/rake_task"

# Gem packaging needs only Bundler's tasks. Loading the dummy Rails app here used
# to make `rake build` boot demo-only gems (and native libvips), so release was the
# first place packaging could fail. All other task invocations retain the engine's
# Rails/db/test tasks for normal development and CI.
gem_only = ARGV.any? && ARGV.all? { _1.match?(/\A(?:build|install|release)(?::|\z)/) }
unless gem_only
  APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
  load "rails/tasks/engine.rake"
end

RuboCop::RakeTask.new

task :brakeman do
  require "brakeman"
  Brakeman.run app_path: ".", print_report: true, pager: false
end

task :test do
  Rails::TestUnit::Runner.run_from_rake("test")
end

task default: %i[rubocop test brakeman]

# Load the gem's own rake tasks under lib/tasks/ (the backlog now lives on the
# holdco-tasks board — see `bin/operate tasks`).
Dir.glob(File.expand_path("lib/tasks/*.rake", __dir__)).sort.each { |f| load f }
