module CafeCar
  module Helpers
    # Returns a new `Context`. Used for instantiating components: `ui.button(:primary, "Submit")`
    def ui
      # For now, this must be defined in a helper instead of in the controller. Passing `view_context` or `helpers`
      # from the controller somehow breaks `capture`. `capture` will return the captured content, but the content
      # _also_ gets appended to the original output buffer.
      # This can be tested in a view by comparing the behavior of `= capture do` with
      # `= controller.view_context.capture do`; the latter outputs the content twice.
      @ui ||= CafeCar::Context.new(self)
    end

    def present(...) = CafeCar[:Presenter].present(self, ...)
  end
end
