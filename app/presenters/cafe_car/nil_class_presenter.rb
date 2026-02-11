module CafeCar
  class NilClassPresenter < self[:Presenter]
    def nil?     = true
    def present? = false
    def blank?   = true

    def then   = self
    def to_str = ""
    def to_ary = []
    def to_html = nil
    def method_missing(...) = self
  end
end
