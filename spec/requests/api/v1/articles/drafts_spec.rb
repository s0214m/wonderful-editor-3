require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:headers) { current_user.create_new_auth_token }
  let(:current_user) { create(:user) }

  describe "GET #index" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let!(:article1) { create(:article, updated_at: 1.day.ago, status: "draft", user: current_user) }
    let!(:article2) { create(:article, updated_at: 2.day.ago, status: "published", user: current_user) }
    let!(:article3) { create(:article, updated_at: 3.day.ago, status: "draft", user: current_user) }

    it "自分の下書き記事が全て表示できる" do
      subject
      res = JSON.parse(response.body)
      expect(res.count).to eq current_user.articles.draft.count
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0].values.count).to eq 5
      expect(res.pluck("id")).to eq [article1.id, article3.id]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(res[0]["user"].values.count).to eq 3
      expect(response).to have_http_status(:ok)
    end
  end

  describe " Get #show" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "適切なIDを指定し" do
      let(:article_id) { article.id }

      context "記事が下書き用の時" do
        let(:article) { create(:article, user: current_user, status: "draft") }
        it "その記事を表示できる" do
          subject
          res = JSON.parse(response.body)
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["status"]).to eq "draft"
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"]["name"]).to eq article.user.name
          expect(res["user"]["email"]).to eq article.user.email
          expect(response).to have_http_status(:ok)
        end
      end

      context "公開用の時" do
        let(:article) { create(:article, status: "published") }
        it "その記事を表示できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "他人の下書きの記事の時" do
        let(:other_user) { create(:user) }
        let(:article) { create(:article, user: other_user) }
        it "表示できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "不適切なIDを指定した時" do
      let(:article_id) { 1_000_000 }
      it "その記事を表示できない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
