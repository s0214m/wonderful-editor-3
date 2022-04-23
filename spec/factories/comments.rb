# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text             default("Comment"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_article_id  (article_id)
#  index_comments_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.characters(number: 10) }
    user
    article
  end
end