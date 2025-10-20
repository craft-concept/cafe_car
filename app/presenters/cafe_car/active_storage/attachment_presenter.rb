module CafeCar
  module ActiveStorage
    class AttachmentPresenter < CafeCar[:Presenter]
      option :size

      # def url = object.representation(resize_to_limit: [100, 100]).processed.path
      def url = object.url
      def blank = options.fetch(:blank) { "(none)" }

      def image
        @template.image_tag url, class: ui.class(:image, size) if url
      end

      def preview = image || blank
    end
  end
end
