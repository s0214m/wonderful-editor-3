# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text             not null
#  title      :string           not null
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
require "rails_helper"

RSpec.describe Article, type: :model do
  context "title, body, userが存在する時" do
    let(:article) { build(:article) }
    it "記事が作成できる" do
      expect(article).to be_valid
    end
  end

  context "titleがない時" do
    let(:article) { build(:article, title: nil) }
    it "バリデーションが効く" do
      expect(article).to be_invalid
      expect(article.errors.messages[:title]).to include("can't be blank")
    end
  end

  context "bodyがない時" do
    let(:article) { build(:article, body: nil) }
    it "バリデーションが効く" do
      expect(article).to be_invalid
      expect(article.errors.messages[:body]).to include("can't be blank")
    end
  end

  context "userが存在しない時" do
    let(:article) { build(:article, user: nil) }
    it "バリデーションが効く" do
      expect(article).to be_invalid
      expect(article.errors.messages[:user]).to include("must exist")
    end
  end
end
