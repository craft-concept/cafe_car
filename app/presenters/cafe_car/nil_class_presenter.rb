module CafeCar
  class NilClassPresenter < self[:Presenter]
    def to_str = ""
    def to_ary = []
    def to_html = nil
    def method_missing(...) = self
  end
end
