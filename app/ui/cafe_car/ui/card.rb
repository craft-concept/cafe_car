module CafeCar
  module UI
    component :Card do
      flag :slim
      option :title
      option :subtitle
      option :image
      option :actions
      option :tabs

      component :Head, :Aside, :Body, :Foot
      component :Title,    tag: :h2
      component :Subtitle, tag: :h3
      component :Image,    tag: :img
      component :Actions
    end
  end
end
