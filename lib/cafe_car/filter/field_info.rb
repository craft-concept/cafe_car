class CafeCar::Filter::FieldInfo < CafeCar[:FieldInfo]
  def i18n(key, **opts)
    I18n.t(@method, scope: [:helpers, :filter, key, i18n_key], raise: true, **opts)
  rescue I18n::MissingTranslationData
  end

  def input
    case type
    when :string   then :text_field
    when :text     then :text_field
    when :integer  then :range_field
    when :datetime then :text_field
    when :password then :password_field
    when :belongs_to, :has_many then :association
    when :has_one
      rich_text? ? :text_field : nil
    else raise "Missing input type for #{model_name}##{@method} of type :#{type}"
    end
  end
end
