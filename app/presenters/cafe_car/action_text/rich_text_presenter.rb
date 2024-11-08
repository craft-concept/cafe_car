module CafeCar
  module ActionText
    class RichTextPresenter < CafeCar[:RecordPresenter]
      def to_html = object.to_s
    end
  end
end
