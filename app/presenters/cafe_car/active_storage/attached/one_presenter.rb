module CafeCar
  module ActiveStorage
    module Attached
      class OnePresenter < AttachmentPresenter
        def href = present(object.attachment).href
      end
    end
  end
end
