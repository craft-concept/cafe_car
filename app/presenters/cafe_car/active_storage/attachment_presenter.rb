module CafeCar
  module ActiveStorage
    class AttachmentPresenter < CafeCar[:Presenter]
      # def url = object.representation(resize_to_limit: [100, 100]).processed.path
      def url = object.url
      def to_html
        raise
        @template.image_tag url
        "hi"
      end
    end
  end
end
