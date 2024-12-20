module CafeCar
  module Pluralization
    def pluralize(locale, entry, count)
      return super unless entry.is_a?(String) && count
      count = 1 if count == :one
      count = 2 unless count.is_a?(Integer)
      entry.pluralize(count)
    end

    def localize(locale, object, format = :default, options = {})
      options[:ordinal] ||= object.day.ordinalize
      super
    end
  end
end
