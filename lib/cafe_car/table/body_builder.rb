module CafeCar::Table
  class BodyBuilder < ObjectsBuilder
    def to_html
      ui.body id: @objects.model_name.plural do |body|
        body << @template.turbo_stream_from(model_name.plural)
        @objects.each do |object|
          body << RowBuilder.new(@template, object:, **@options, &@block)
        end
      end
    end
  end
end
