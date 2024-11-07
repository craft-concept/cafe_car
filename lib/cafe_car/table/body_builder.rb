module CafeCar::Table
  class BodyBuilder < ObjectsBuilder
    def to_html
      ui.body do |body|
        @objects.each do |object|
          body << RowBuilder.new(@template, object:, **@options, &@block)
        end
      end
    end
  end
end
