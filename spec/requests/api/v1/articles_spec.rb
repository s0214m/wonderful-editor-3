require "rails_helper"

RSpec.describe "/api/v1/articles", type: :request do
  describe "GET #index" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.day.ago) }
    let!(:article2) { create(:article, updated_at: 2.day.ago) }
    let!(:article3) { create(:article, updated_at: 3.day.ago) }
    it "全投稿が表示できる" do
      subject
      res = JSON.parse(response.body)
      expect(res.count).to eq Article.count
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0].values.count).to eq 4
      expect(res.pluck("id")).to eq [article1.id, article2.id, article3.id]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(res[0]["user"].values.count).to eq 3
      expect(response).to have_http_status(:ok)
    end
  end

  describe " Get #show" do
    subject { get(api_v1_article_path(article_id)) }

    context "全ての情報がある時" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }
      it "その投稿を表示できる" do
        subject
        res = JSON.parse(response.body)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"]["name"]).to eq article.user.name
        expect(res["user"]["email"]).to eq article.user.email
      end
    end

    context "指定したidが異なるとき" do
      let(:article_id) { 1_000_000 }
      let(:article) { create(:article) }
      it "その投稿を表示できない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
