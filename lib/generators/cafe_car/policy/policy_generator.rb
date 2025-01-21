class CafeCar::PolicyGenerator < Rails::Generators::NamedBase
  include CafeCar[:Generators]

  source_root File.expand_path("templates", __dir__)

  check_class_collision suffix: "Policy"

  def create_policy
    template "policy.rb", File.join("app/policies", class_path, "#{file_name}_policy.rb")
  end

  private

  def base_policy_name = "ApplicationPolicy"

  def model  = @model ||= CafeCar[:ModelInfo].new(class_name.constantize)
  def fields = model.editable_fields

  def title_attribute = fields.first.try(&:method).then(&:inspect)

  def permitted_attributes
    # TODO: replace *_digest with * and *_confirmation
    # TODO: handle attachments
    params  = fields.map { ":#{_1.method}" }
    params.join(", ")
  end
end
