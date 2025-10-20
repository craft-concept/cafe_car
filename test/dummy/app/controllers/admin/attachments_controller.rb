module Admin
  class AttachmentsController < ApplicationController
    recline_in_the_cafe_car
    model ::ActiveStorage::Attachment
  end
end
