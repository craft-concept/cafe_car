require "rails/generators/active_record/migration"

module CafeCar::Generators
  extend ActiveSupport::Concern
  include ActiveRecord::Generators::Migration

  private

  def migration(name, ...) = migration_template("#{name}.rb", "db/migrate/#{name}.rb", ...)

  def class_namespace = class_path.join('/').classify

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
