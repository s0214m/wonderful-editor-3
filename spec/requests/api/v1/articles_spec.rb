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

    context "適切なIDを指定した時" do
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
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なIDを指定した時" do
      let(:article_id) { 1_000_000 }
      let(:article) { create(:article) }
      it "その投稿を表示できない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe " POST #create" do
    subject { post(api_v1_articles_path, params: params) }

    let!(:current_user) { create(:user) }
    let(:params) { { article: attributes_for(:article) } }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    it "投稿を作成できる" do
      expect { subject }.to change { current_user.articles.count }.by(1)
      res = JSON.parse(response.body)
      expect(res["id"]).to eq current_user.articles.last.id
      expect(res["title"]).to eq params[:article][:title]
      expect(res["body"]).to eq params[:article][:body]
      expect(res["updated_at"]).to be_present
      expect(res["user"]["id"]).to eq current_user.id
      expect(res["user"]["name"]).to eq current_user.name
      expect(res["user"]["email"]).to eq current_user.email
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    subject { patch(api_v1_article_path(article_id), params: params) }

    let!(:article1) { create(:article, user: current_user) }
    let!(:article2) { create(:article, user: current_user) }
    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "自分の投稿を更新しようとした時" do
      let(:article_id) { article1.id }

      it "更新できる" do
        expect { subject }.to change { article1.reload.title }.from(article1.title).to(params[:article][:title]) &
                              change { article1.reload.body }.from(article1.body).to(params[:article][:body])
        res = JSON.parse(response.body)
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq current_user.id
        expect(res["user"]["name"]).to eq current_user.name
        expect(res["user"]["email"]).to eq current_user.email
        expect(response).to have_http_status(:ok)
      end
    end

    context "他人の投稿を更新しようとした時" do
      let(:other_user) { create(:user) }
      let(:article3) { create(:article, user: other_user) }
      let(:article_id) { article3.id }
      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe " DELETE #destroy" do
    subject { delete(api_v1_article_path(article.id)) }

    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "自分の投稿を削除しようとした時" do
      let!(:article) { create(:article, user: current_user) }
      it "削除できる" do
        expect { subject }.to change { current_user.articles.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "他人の投稿を削除しようとした時" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      it "削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
