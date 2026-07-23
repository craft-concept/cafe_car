module CafeCar
  module ActiveStorage
    module Attached
      class ManyPresenter < CafeCar[:Presenter]
        # Present the attachments collection itself — it routes through
        # Relation/Enumerable presentation as a compact, counted list of
        # AttachmentPresenter previews (thumbnails or file links).
        def to_html = present(object.attachments, **options)
      end
    end
  end
end
