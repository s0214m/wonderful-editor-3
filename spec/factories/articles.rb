# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text             not null
#  status     :string
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_status   (status)
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :article do
    title { Faker::Lorem.characters(number: 10) }
    body { Faker::Lorem.characters(number: 10) }
    status { "draft" }
    user

    trait :with_comments do
      after(:build) do |article|
        user = create(:user)
        create(:comment, article: article, user: user)
      end
    end

    trait :with_article_likes do
      after(:build) do |article|
        user = create(:user)
        create(:article_like, article: article, user: user)
      end
    end

    trait :with_article_likes_with_comments do
      after(:build) do |article|
        user = create(:user)
        create(:article_like, article: article, user: user)
        create(:comment, article: article, user: user)
      end
    end
  end
end
