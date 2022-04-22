FactoryBot.define do
  factory :user do
    sequence(:name) {|n| "#{n}_#{Faker::Internet.username}" }
    sequence(:email) {|n| "#{n}_#{Faker::Internet.email}" }
    sequence(:password) {|n| "#{n}_#{Faker::Internet.password}" }

    trait :with_articles do
      after(:build) do |user|
        create(:article, user: user)
      end
    end

    trait :with_articles_with_comments do
      after(:build) do |user|
        article = create(:article, user: user)
        create(:comment, user: user, article: article)
      end
    end

    trait :with_articles_with_article_likes do
      after(:build) do |user|
        article = create(:article, user: user)
        create(:article_like, user: user, article: article)
      end
    end

    trait :with_articles_with_article_likes_with_comments do
      after(:build) do |user|
        article = create(:article, user: user)
        create(:article_like, user: user, article: article)
        create(:comment, user: user, article: article)
      end
    end
  end
end
