module CafeCar
  class HashPresenter < self[:CodePresenter]
    def lexer  = Rouge::Lexers::JSON.new
    def source = JSON.pretty_generate(object)
  end
end
