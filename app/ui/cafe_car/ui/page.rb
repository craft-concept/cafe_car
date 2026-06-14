module CafeCar
  module UI
    component :Page do
      flag :slim
      option :title
      option :actions
      option :tabs

      component :Head, :Aside, :Body, :Foot
      component :Title, tag: :h2
      component :Actions
    end
  end
end
