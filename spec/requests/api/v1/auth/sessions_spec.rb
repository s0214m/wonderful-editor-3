require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /create" do
    subject { post(api_v1_user_session_path, params: params) }

    let!(:current_user) { create(:user) }
    let!(:other_user) { create(:user) }
    context "適切な情報を送信した時" do
      let(:params) { { email: current_user.email, password: current_user.password } }
      it "ログインできる" do
        expect { subject }.to change { current_user.reload.tokens }.from(be_blank).to(be_present)
        res = JSON.parse(response.body)["data"]
        expect(res["id"]).to eq current_user.id
        expect(res["name"]).to eq current_user.name
        expect(res["email"]).to eq current_user.email
        expect(response).to have_http_status(:ok)
      end

      it "ヘッダー情報が取得できる" do
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
      let(:params) { { email: other_user.email, password: current_user.password } }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to eq false
        expect(res["errors"]).to include("Invalid login credentials. Please try again.")
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "不適切なpasswordを送信した時" do
      let(:params) { { email: current_user.email, password: other_user.password } }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to eq false
        expect(res["errors"]).to include("Invalid login credentials. Please try again.")
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "別のユーザーがログインしようとした時" do
      let(:user) { build(:user) }
      let(:params) { { email: user.email, password: user.password } }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to eq false
        expect(res["errors"]).to include("Invalid login credentials. Please try again.")
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /destroy" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ログインしているユーザーがいる時" do
      let(:current_user) { create(:user) }
      let!(:headers) { current_user.create_new_auth_token }
      it "ログアウトできる" do
        expect { subject }.to change { current_user.reload.tokens }.from(be_present).to(be_blank)
        res = JSON.parse(response.body)
        expect(res["success"]).to eq true
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
