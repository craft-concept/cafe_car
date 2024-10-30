class User < ApplicationRecord
  has_many :articles, inverse_of: :author
end
