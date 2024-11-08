module CafeCar
  module TurboTagBuilder
    def dialog_for(record, prefix = :dialog, **, &)
      id = @view_context.dom_id(record, prefix)
      action(:dialog, id, **) do
        @view_context.tag.dialog(id:, class: @view_context.ui_class(:dialog), &)
      end
    end
  end
end
