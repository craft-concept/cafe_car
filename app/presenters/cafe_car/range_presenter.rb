module CafeCar
  class RangePresenter < CafeCar[:Presenter]
    def to_s
      min, max = object.begin, object.end
      if min.blank? && max.blank?
        ""
      elsif max.blank? || max == Float::INFINITY
        "#{min}+"
      elsif min == max
        min
      else
        "#{min} – #{max}"
      end
    end
  end
end
