print "Creating users... "
30.times do
  User.create name:     Faker::Religion::Bible.unique.character,
              password: pw = Faker::Internet.password,
              password_confirmation: pw
end
puts "Done."

users = User.all
print "Creating articles... "
100.times do
  Article.create title:        Faker::Book.unique.title,
                 author:       users.sample,
                 published_at: Faker::Time.between(from: 5.years.ago, to: 1.month.from_now),
                 summary:      Faker::Religion::Bible.quote,
                 body:         Faker::Hipster.paragraphs.join("<br><br>")
end
puts "Done."
