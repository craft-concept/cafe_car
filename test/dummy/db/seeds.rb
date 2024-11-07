30.times do
  User.create username: Faker::Religion::Bible.unique.character
end

users = User.all

100.times do
  Article.create title: Faker::Book.unique.title,
                 author: users.sample,
                 published_at: Faker::Time.backward(days: 1000)
end
