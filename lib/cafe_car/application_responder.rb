require "responders"

module CafeCar
  class ApplicationResponder < ActionController::Responder
    include Responders::FlashResponder
    include Responders::HttpCacheResponder

    self.error_status    = :unprocessable_entity
    self.redirect_status = :see_other

    def to_turbo_stream
      # Put :html back in the accepted format list. respond_with removes it
      controller.lookup_context.formats << :html
      to_html
    end
  end
end
