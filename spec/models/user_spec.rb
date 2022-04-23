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
require "rails_helper"

RSpec.describe User, type: :model do
  context "name, email, passwordが存在する時" do
    let(:user) { build(:user) }
    it "ユーザーが作られる" do
      expect(user).to be_valid
    end
  end

  context "nameが存在しない時" do
    let(:user) { build(:user, name: nil) }
    it "ユーザーが作られない" do
      expect(user).to be_invalid
      expect(user.errors.messages[:name]).to include("can't be blank")
    end
  end

  context "emailが存在しない時" do
    let(:user) { build(:user, email: nil) }
    it "ユーザーが作られない" do
      expect(user).to be_invalid
      expect(user.errors.messages[:email]).to include("can't be blank")
    end
  end

  context "passwordが存在しない時" do
    let(:user) { build(:user, password: nil) }
    it "ユーザーが作られない" do
      expect(user).to be_invalid
      expect(user.errors.messages[:password]).to include("can't be blank")
    end
  end

  context "同じemailが既に存在する時" do
    before { create(:user, email: "user1@test.com") }

    it "ユーザーが作られない" do
      user = build(:user, email: "user1@test.com")
      expect(user).to be_invalid
      expect(user.errors.messages[:email]).to include("has already been taken")
    end
  end
end
