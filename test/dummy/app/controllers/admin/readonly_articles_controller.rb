module Admin
  # Exercises `cafe_car only:` narrowing: index/show work, every other CafeCar
  # action responds 404 — never a crash (see narrowing_test.rb). Its routes are
  # drawn in full so the controller's own gate is what gets hit.
  class ReadonlyArticlesController < ApplicationController
    cafe_car only: %i[index show], model: Article
  end
end
