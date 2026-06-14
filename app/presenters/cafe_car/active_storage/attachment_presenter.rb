module CafeCar
  module ActiveStorage
    class AttachmentPresenter < CafeCar[:Presenter]
      option :size

      # def url = object.representation(resize_to_limit: [300, 300])&.processed&.url
      def url = object.try(:url)
      def blank = options[:blank]
      def logo = self

      def image
        @template.image_tag url, **options, class: ui.class(:image, size) if url
      end

      def preview = image || blank
    end
  end
end
