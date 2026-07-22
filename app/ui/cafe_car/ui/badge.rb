module CafeCar
  module UI
    component :Badge, tag: :span do
      flag :success
      flag :warning
      flag :danger
      flag :info
    end
  end
end
