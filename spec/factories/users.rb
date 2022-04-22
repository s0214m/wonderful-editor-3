# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default("sample@example.com"), not null
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string           default("unknown"), not null
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
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
