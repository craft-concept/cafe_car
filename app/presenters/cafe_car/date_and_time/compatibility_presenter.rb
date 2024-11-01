module CafeCar
  module DateAndTime
    class CompatibilityPresenter < Presenter
      def to_s = @template.l(object)
    end
  end
end
