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
require "rails_helper"

RSpec.describe Comment, type: :model do
  context "body, user, articleが存在する時" do
    let(:comment) { build(:comment) }
    it "コメントが作成できる" do
      expect(comment).to be_valid
    end
  end

  context "bodyがない時" do
    let(:comment) { build(:comment, body: nil) }
    it "コメントが作成できない" do
      expect(comment).to be_invalid
      expect(comment.errors.messages[:body]).to include("can't be blank")
    end
  end

  context "userがない時" do
    let(:comment) { build(:comment, user: nil) }
    it "コメントが作成できない" do
      expect(comment).to be_invalid
      expect(comment.errors.messages[:user]).to include("must exist")
    end
  end

  context "articleがない時" do
    let(:comment) { build(:comment, article: nil) }
    it "コメントが作成できない" do
      expect(comment).to be_invalid
      expect(comment.errors.messages[:article]).to include("must exist")
    end
  end
end
