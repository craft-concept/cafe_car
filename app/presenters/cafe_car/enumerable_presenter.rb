module CafeCar
  class EnumerablePresenter < self[:Presenter]
    def to_html
      out = safe_join(object.map { show(_1) }, ', ')
      return options[:empty] || '(none)' if out.blank?
      out
    end
  end
end
#
# return options[:empty] || '(none)' if object.empty?
#
# safe_join [
#             *([object.size, ' total: '] if options[:count]),
#             safe_join(object.map {|v| show(v, **options) }, ', ')
#           ].compact
