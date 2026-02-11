module CafeCar
  module ActionText
    class RichTextPresenter < CafeCar[:RecordPresenter]
      def to_html = object
    end
  end
end
