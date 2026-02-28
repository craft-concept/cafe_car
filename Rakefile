require "bundler/setup"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

task :brakeman do
  require "brakeman"
  Brakeman.run app_path: ".", print_report: true, pager: false
end

task :test do
  Rails::TestUnit::Runner.run_from_rake("test")
end

task default: %i[rubocop test brakeman]
