FactoryBot.define do
  factory :user do
    username { Faker::Religion::Bible.unique.character }
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
      published_at { Faker::Time.between(from: 5.years.ago, to: Time.now) }
    end

    trait :draft do
      published_at { Faker::Time.between(from: Time.now, to: 1.month.from_now) }
    end
  end
end
