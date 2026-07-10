module CafeCar
  module Inputs
    # An Action Text `<trix-editor>` (with its hidden input) for `has_rich_text`
    # associations.
    class RichTextInput < BaseInput
      def helper = :rich_text_area
    end
  end
end
