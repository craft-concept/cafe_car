class CafeCar::PolicyGenerator < Rails::Generators::NamedBase
  include CafeCar[:Generators]

  source_root File.expand_path("templates", __dir__)

  argument :permitted, type: :array, default: [], banner: "field [...]"

  check_class_collision suffix: "Policy"

  def create_policy
    template "policy.rb", File.join("app/policies", class_path, "#{file_name}_policy.rb")
  end

  private

  def base_policy_name = "ApplicationPolicy"

  def model_class = class_name.classify.safe_constantize

  def model  = @model ||= CafeCar[:ModelInfo].new(model_class)

  def attribute_names
    @attribute_names ||= permitted.presence || model.editable_fields.map(&:method)
  end

  def title_attribute
    return ":could_not_find_model" if model_class.nil?
    attribute_names.first.then { ":#{_1}" }
  end

  def permitted_attributes
    return ":create_model_first_to_generate_attributes" if model_class.nil?

    # TODO: replace *_digest with * and *_confirmation
    # TODO: handle attachments
    params  = attribute_names.map { ":#{_1}" }
    params.join(", ")
  end
end
