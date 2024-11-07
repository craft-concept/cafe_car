module CafeCar
  class StringPresenter < self[:Presenter]
    def title = to_s

    def to_s
      length = @options[:truncate]
      txt    = object
      txt    = @template.truncate(txt, length:) if length

      case object
      when %r{^https?://.+\.(png|jpe?g|svg)$}
        @template.image_tag object, style: 'width: 1em'
      when %r{^https?://}
        link_to(txt, object, target: '_blank', rel: "noopener")
      else
        txt
      end
    end
  end
end
