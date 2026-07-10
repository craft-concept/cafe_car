module CafeCar
  module Inputs
    # A file picker `<input type="file">` for Active Storage attachments. A
    # `has_many_attached` field renders a multiple picker so several files upload
    # at once.
    class FileInput < BaseInput
      def helper   = :file_field
      def defaults = info.multiple? ? { multiple: true } : {}
    end
  end
end
