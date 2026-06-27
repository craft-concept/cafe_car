require "rails/generators/active_record/migration"
require "rails/generators/bundle_helper"
require "shellwords"

module CafeCar::Generators
  extend ActiveSupport::Concern
  include ActiveRecord::Generators::Migration
  include Rails::Generators::BundleHelper

  private

  # Delegate to another generator inline, anchored to THIS generator's
  # destination_root. Rails' built-in `generate` action recomputes the
  # destination from Rails::Command.root, which leaks writes into the engine
  # repo (when a contributor runs the generator there) or escapes the test
  # destination. Invoking the generator directly keeps every sub-generator
  # writing where the parent does.
  def generate(what, *args)
    args.extract_options! # drop trailing option hashes (e.g. inline:); always inline here
    what, *args = Shellwords.split("#{what} #{args.map(&:to_s).join(' ')}")
    Rails::Generators.invoke(what, args, behavior: behavior, destination_root: destination_root)
  end

  def migration(name, ...) = migration_template("#{name}.rb", "db/migrate/#{name}.rb", ...)

  def model(name, ...)
    name = name.chomp(".rb").underscore
    template("#{name}.rb", "app/models/#{name}.rb", ...)
  end

  def class_namespace = class_path.join("/").classify

  def module_namespacing(&block)
    super { concat wrap_with_module(class_namespace, &block) }
  end

  def wrap_with_module(module_name, &block)
    content = capture(&block)
    return content if module_name.blank?
    content = indent(content).chomp
    "module #{module_name}\n#{content}\nend\n"
  end
end
