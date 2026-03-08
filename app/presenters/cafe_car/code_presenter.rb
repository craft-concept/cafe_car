module CafeCar
  class CodePresenter < self[:Presenter]
    def formatter = Rouge::Formatters::HTML.new
    def source    = object.to_s
    def formatted = formatter.format(lexer.lex(source))

    def options_lexer = options[:lang].try { Rouge::Lexer.find(_1) }
    def guess_lexer = Rouge::Lexer.guess(source:)

    def lexer
      @lexer ||= options_lexer || guess_lexer
    end

    def to_html
      ui.Code(formatted.html_safe, class: ['highlight', lexer.tag])
    end
  end
end
