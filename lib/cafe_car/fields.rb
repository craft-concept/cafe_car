module CafeCar
  class Fields < Array
    include Caching

    derive :editable, -> { reject(&:constant?) }
    derive :listable, -> { editable.reject(&:digest?) }
  end
end
