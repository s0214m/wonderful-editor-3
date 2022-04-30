require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  let(:headers) { current_user.create_new_auth_token }
  let(:current_user) { create(:user) }

  describe "GET #index" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    let!(:article1) { create(:article, updated_at: 1.day.ago, status: "published", user: current_user) }
    let!(:article2) { create(:article, updated_at: 2.day.ago, status: "draft", user: current_user) }
    let!(:article3) { create(:article, updated_at: 3.day.ago, status: "published", user: current_user) }

    it "自分の公開記事が全て表示できる" do
      subject
      res = JSON.parse(response.body)
      expect(res.count).to eq current_user.articles.published.count
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0].values.count).to eq 5
      expect(res.pluck("id")).to eq [article1.id, article3.id]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(res[0]["user"].values.count).to eq 3
      expect(response).to have_http_status(:ok)
    end
  end
end
