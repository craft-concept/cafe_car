module Admin
  class InvoicesController < ApplicationController
    recline_in_the_cafe_car

    def new
      @invoice.line_items.build
    end

    def edit
      @invoice.line_items.build
    end
  end
end
