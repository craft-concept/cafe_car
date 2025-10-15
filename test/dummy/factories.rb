require "open-uri"

FactoryBot.define do
  factory :user do
    name     { Faker::Religion::Bible.unique.character }
    password { @pw = Faker::Internet.password }
    password_confirmation { @pw }
    avatar { {io: URI.parse(Faker::Avatar.image).open, filename: "avatar.png"} }
  end

  factory :article do
    title  { Faker::Book.unique.title }
    author { User.sample or create(:user) }

    trait :content do
      summary { Faker::Religion::Bible.quote }
      body    { Faker::Lorem.paragraphs.join("<br><br>") }
    end

    trait :published do
      published_at { Faker::Time.between(from: 5.years.ago, to: Time.current) }
    end

    trait :draft do
      published_at { Faker::Time.between(from: Time.current, to: 1.month.from_now) }
    end
  end

  factory :client do
    name  { Faker::Company.unique.name }
    owner { User.sample or create(:user) }
  end

  factory :invoice do
    line_items { build_list(:line_item, rand(1..10)) }
    client     { Client.sample or create(:client) }
    sender     { client.owner }
    issued_on  { Date.today - rand(-30..1000) }
    due_on     { issued_on + [30, 60, 90].sample }
    note       { Faker::Lorem.paragraph }
  end

  factory :line_item do
    price       { rand(10.0..900.0).round(2) }
    quantity    { rand(1..200) }
    description { Faker::Lorem.sentence }
  end
end
