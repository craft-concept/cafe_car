module CafeCar
  module Table
    class BodyBuilder < Builder
      def to_html
        ui.body do |body|
          @object.each do |object|
            body << RowBuilder.new(@template, object, **@options, &@block)
          end
        end
      end
    end
  end
end
