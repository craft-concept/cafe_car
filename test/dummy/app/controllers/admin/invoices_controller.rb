module Admin
  class InvoicesController < ApplicationController
    cafe_car

    def new
      @invoice.line_items.build
    end

    def edit
      @invoice.line_items.build
    end
  end
end
