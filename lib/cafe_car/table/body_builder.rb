module CafeCar::Table
  class BodyBuilder < Builder
    def initialize(...)
      super
      @objects = @options.delete(:objects) { raise }
    end

    def to_html
      ui.body do |body|
        @objects.each do |object|
          body << RowBuilder.new(@template, object:, **@options, &@block)
        end
      end
    end
  end
end
