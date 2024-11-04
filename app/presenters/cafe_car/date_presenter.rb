module CafeCar
  class DatePresenter < Presenter
    def to_html
      tag.time l(object), datetime: object.iso8601, title: l(object, format: :long)
    end
  end
end
