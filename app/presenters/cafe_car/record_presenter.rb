module CafeCar
  class RecordPresenter < CafeCar[:Presenter]
    show :id, -> { "##{_1}" }
  end
end
