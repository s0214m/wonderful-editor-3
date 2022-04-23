# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text             default("Content"), not null
#  title      :string           default("Title"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Article < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :article_likes, dependent: :destroy
  belongs_to :user

  validates :title, presence: true
  validates :body, presence: true
end
