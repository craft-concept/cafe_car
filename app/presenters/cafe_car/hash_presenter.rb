module CafeCar
  class HashPresenter < self[:Presenter]
    def formatter = Rouge::Formatters::HTML.new
    def lexer     = Rouge::Lexers::JSON.new
    def source    = JSON.pretty_generate(object)

    def to_html
      tag.code(formatter.format(lexer.lex(source)).html_safe, class: 'highlight')
    end
  end
end
