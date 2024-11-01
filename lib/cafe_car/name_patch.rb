module CafeCar
  module NamePatch
    def self.patch!
      ActiveModel::Name.class_eval do
        def human(options = {})
          return @human if i18n_keys.empty? || i18n_scope.empty?

          key, *defaults = i18n_keys
          defaults << options[:default] if options[:default]
          defaults << @human

          I18n.translate(key, scope: i18n_scope, count: 1, **options, default: defaults)
        end
      end
    end
  end
end
