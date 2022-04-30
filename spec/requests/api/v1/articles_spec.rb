require "rails_helper"

RSpec.describe "/api/v1/articles", type: :request do
  describe "GET #index" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.day.ago, status: "published") }
    let!(:article2) { create(:article, updated_at: 2.day.ago, status: "draft") }
    let!(:article3) { create(:article, updated_at: 3.day.ago, status: "published") }
    it "公開されている全記事が表示できる" do
      subject
      res = JSON.parse(response.body)
      expect(res.count).to eq Article.published.count
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0].values.count).to eq 5
      expect(res.pluck("id")).to eq [article1.id, article3.id]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(res[0]["user"].values.count).to eq 3
      expect(response).to have_http_status(:ok)
    end
  end

  describe " Get #show" do
    subject { get(api_v1_article_path(article_id)) }

    context "適切なIDを指定して" do
      context "公開されている時" do
        let(:article_id) { article.id }
        let(:article) { create(:article, status: "published") }
        it "その記事を表示できる" do
          subject
          res = JSON.parse(response.body)
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["status"]).to eq "published"
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"]["name"]).to eq article.user.name
          expect(res["user"]["email"]).to eq article.user.email
          expect(response).to have_http_status(:ok)
        end
      end

      context "下書きの時" do
        let(:article_id) { article.id }
        let(:article) { create(:article, status: "draft") }
        it "その記事を取得できない" do
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

  describe " POST #create" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let!(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    context "公開用として" do
      let(:params) { { article: attributes_for(:article, status: "published") } }
      it "記事を作成できる" do
        expect { subject }.to change { current_user.articles.published.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["id"]).to eq current_user.articles.published.last.id
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "published"
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq current_user.id
        expect(res["user"]["name"]).to eq current_user.name
        expect(res["user"]["email"]).to eq current_user.email
        expect(response).to have_http_status(:ok)
      end
    end

    context "下書き用として" do
      let(:params) { { article: attributes_for(:article, status: "draft") } }
      it "記事を作成できる" do
        expect { subject }.to change { current_user.articles.draft.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["id"]).to eq current_user.articles.draft.last.id
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "draft"
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq current_user.id
        expect(res["user"]["name"]).to eq current_user.name
        expect(res["user"]["email"]).to eq current_user.email
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なstatusを送信した時" do
      let(:params) { { article: attributes_for(:article, status: "unpublished") } }
      it "エラーする" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe "PATCH #update" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "公開されている自分の記事を" do
      let!(:article) { create(:article, user: current_user, status: "published") }
      context "公開用として" do
        let(:params) { { article: attributes_for(:article, status: "published") } }
        it "更新できる" do
          expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                                change { article.reload.body }.from(article.body).to(params[:article][:body])
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "published"
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq current_user.id
          expect(res["user"]["name"]).to eq current_user.name
          expect(res["user"]["email"]).to eq current_user.email
          expect(response).to have_http_status(:ok)
        end
      end

      context "下書き用として" do
        let(:params) { { article: attributes_for(:article, status: "draft") } }
        it "更新できる" do
          expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                                change { article.reload.body }.from(article.body).to(params[:article][:body])
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "draft"
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq current_user.id
          expect(res["user"]["name"]).to eq current_user.name
          expect(res["user"]["email"]).to eq current_user.email
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "下書き用の自分の記事を" do
      let!(:article) { create(:article, user: current_user, status: "draft") }
      context "公開用として" do
        let(:params) { { article: attributes_for(:article, status: "published") } }
        it "更新できる" do
          expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                                change { article.reload.body }.from(article.body).to(params[:article][:body])
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "published"
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq current_user.id
          expect(res["user"]["name"]).to eq current_user.name
          expect(res["user"]["email"]).to eq current_user.email
          expect(response).to have_http_status(:ok)
        end
      end

      context "下書き用として" do
        let(:params) { { article: attributes_for(:article, status: "draft") } }
        it "更新できる" do
          expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                                change { article.reload.body }.from(article.body).to(params[:article][:body])
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "draft"
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq current_user.id
          expect(res["user"]["name"]).to eq current_user.name
          expect(res["user"]["email"]).to eq current_user.email
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "他人の投稿を更新しようとした時" do
      let(:params) { { article: attributes_for(:article, status: "published") } }
      let(:other_user) { create(:user) }
      let(:article) { create(:article, user: other_user, status: "published") }
      let(:article_id) { article.id }
      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe " DELETE #destroy" do
    subject { delete(api_v1_article_path(article.id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

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
