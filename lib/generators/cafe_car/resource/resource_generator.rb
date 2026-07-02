require "rails/generators/resource_helpers"

class CafeCar::ResourceGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)
  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

  def create_model
    generate "model", file_path, *attributes, force
  end

  def create_controller
    generate "cafe_car:controller", controller_name, force
  end

  def create_policy
    generate "cafe_car:policy", file_path, *field_names, force
  end

  private

  # The policy generator wants bare field names (`name price`), not the model
  # generator's `field:type:index` form. Forwarding them lets the policy list
  # real permitted attributes instead of falling back to model introspection,
  # which can't see a model that isn't a loaded constant yet mid-run.
  #
  # A `:references`/`belongs_to` field must be permitted by its foreign key
  # (`invoice_id`), not the bare association (`invoice`) — that's the column
  # strong-params actually receives. Polymorphic refs need `_id` + `_type`
  # (mirrors notes_generator's hardcoded `notable_id notable_type`).
  def field_names
    attributes.flat_map do |attr|
      next attr.name unless attr.reference?

      [ "#{attr.name}_id", ("#{attr.name}_type" if attr.polymorphic?) ].compact
    end
  end

  def assign_controller_names!(...)
    if options[:model_name].blank?
      assign_names!(file_name)
    end

    super
  end

  def force = options.force? ? "--force" : ""
end
