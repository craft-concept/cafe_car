class CafeCar::PolicyGenerator < Rails::Generators::NamedBase
  include CafeCar[:Generators]

  source_root File.expand_path("templates", __dir__)

  argument :permitted, type: :array, default: [], banner: "field [...]"

  check_class_collision suffix: "Policy"

  def create_policy
    template "policy.rb", File.join("app/policies", class_path, "#{file_name}_policy.rb")
  end

  private

  # Use the leaf name inside the template; module_namespacing already emits the
  # surrounding `module Admin`, so the full path would double-namespace it
  # (`module Admin; class Admin::PaymentPolicy`). Mirrors the controller generator.
  def class_name = file_name.camelize

  def base_policy_name = "ApplicationPolicy"

  def model_class = file_path.classify.safe_constantize

  def model  = @model ||= CafeCar[:ModelInfo].new(model: model_class)

  def attribute_names
    @attribute_names ||= permitted.presence || model_fields
  end

  # Introspect the model's editable columns, but only when it resolves to a
  # loaded constant — a resource run writes the model file first but may not
  # have autoloaded it yet, in which case the caller forwards explicit fields.
  def model_fields
    return [] if model_class.nil?

    model.fields.editable.map(&:method)
  end

  def title_attribute
    return ":could_not_find_model" if attribute_names.blank?
    attribute_names.first.then { ":#{_1}" }
  end

  def permitted_attributes
    return ":create_model_first_to_generate_attributes" if attribute_names.blank?

    # TODO: replace *_digest with * and *_confirmation
    # TODO: handle attachments
    params  = attribute_names.map { ":#{_1}" }
    params.join(", ")
  end
end
