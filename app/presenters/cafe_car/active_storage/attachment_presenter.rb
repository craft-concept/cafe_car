module CafeCar
  module ActiveStorage
    class AttachmentPresenter < CafeCar[:Presenter]
      option :size

      # def url = object.representation(resize_to_limit: [300, 300])&.processed&.url
      def url = object.try(:url)
      def blank = options[:blank]
      # An attachment is its own logo — it renders as its own image. Keep the base
      # `logo(*, **, &)` signature so callers (e.g. the grid item's `logo(href:)`)
      # don't hit an arity mismatch; the args aren't needed since we return self.
      def logo(*, **, &) = self

      def image
        @template.image_tag url, **options, class: ui.class(:image, size) if url
      end

      def preview = image || blank
    end
  end
end
