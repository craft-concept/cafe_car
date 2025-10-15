module CafeCar
  module ActiveStorage
    module Attached
      class OnePresenter < CafeCar[:Presenter]
        def url = object.url
        def to_html = url&.then { @template.image_tag url } || "(none)"
      end
    end
  end
end
