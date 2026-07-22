module Admin
  # Exercises `cafe_car except:` narrowing: destroy responds 404, everything
  # else still works (see narrowing_test.rb). Its routes are drawn in full so
  # the controller's own gate is what gets hit.
  class PermanentArticlesController < ApplicationController
    cafe_car except: %i[destroy], model: Article
  end
end
