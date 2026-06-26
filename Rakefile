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

# Holdco backlog machinery (tasks:new, tasks:index, tasks:claim, tasks:done, rake task).
# Loads every .rake under lib/tasks/ so the gem's own tasks and holdco_tasks both run.
Dir.glob(File.expand_path("lib/tasks/*.rake", __dir__)).sort.each {|f| load f }
