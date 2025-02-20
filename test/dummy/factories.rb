FactoryBot.define do
  factory :user do
    name     { Faker::Religion::Bible.unique.character }
    password { @pw = Faker::Internet.password }
    password_confirmation { @pw }
  end

  factory :article do
    title { Faker::Book.unique.title }
    author { create(:user) }

    trait :sample_author do
      author { User.all.sample }
    end

    trait :content do
      summary { Faker::Religion::Bible.quote }
      body    { Faker::Hipster.paragraphs.join("<br><br>") }
    end

    trait :published do
      published_at { Faker::Time.between(from: 5.years.ago, to: Time.current) }
    end

    trait :draft do
      published_at { Faker::Time.between(from: Time.current, to: 1.month.from_now) }
    end
  end

  factory :client do
    name { Faker::Company.unique.name }
    owner { create(:user) }
  end

  factory :invoice do
    line_items { build_list(:line_item, (1..10).to_a.sample) }
  end
end
