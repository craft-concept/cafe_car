module CafeCar
  module UI
    component :Page do
      flag :slim

      component :Head, :Aside, :Body, :Foot
      component :Title, :Actions
    end
  end
end
