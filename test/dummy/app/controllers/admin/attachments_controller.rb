module Admin
  class AttachmentsController < ApplicationController
    cafe_car
    model ::ActiveStorage::Attachment
    default_view :grid
  end
end
