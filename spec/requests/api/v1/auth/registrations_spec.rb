require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /create" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "適切なparamsを送信したとき" do
      let(:params) { attributes_for(:user) }
      it "ユーザーが作成される" do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "success"
        expect(res["data"]["id"]).to eq User.last.id
        expect(res["data"]["name"]).to eq params[:name]
        expect(res["data"]["email"]).to eq params[:email]
        expect(res["data"]["created_at"]).to be_present
        expect(response).to have_http_status(:ok)
      end

      it "ヘッダーを取得できる" do
        subject
        headers = response.headers
        expect(headers["access-token"]).to be_present
        expect(headers["token-type"]).to be_present
        expect(headers["client"]).to be_present
        expect(headers["expiry"]).to be_present
        expect(headers["uid"]).to be_present
      end
    end

    context "不適切なemailを送信した時" do
      let(:params) { { name: "user1", email: "a@g", password: "password" } }
      it "ユーザーが作成できない" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "error"
        expect(res["errors"]["email"]).to include("is not an email")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
