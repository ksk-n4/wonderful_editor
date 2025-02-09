require "rails_helper"

RSpec.describe "Api::V1::Auth::Registration", type: :request do
  describe "POST /api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "適切なパラメータを送信したとき" do
      let(:params) { attributes_for(:user) }

      it "ユーザーの新規登録ができる" do
        expect { subject }.to change { User.count }.by(1)
        expect(response).to have_http_status(200)
        res = JSON.parse(response.body)
        expect(res["data"]["name"]).to eq(User.last.name)
        expect(res["data"]["email"]).to eq(User.last.email)
      end

      it "header 情報を取得することができる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "name がないとき" do
      let(:params) { attributes_for(:user, name: nil) }

      it "新規登録できない" do
        expect { subject }.to not_change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(422)
        expect(res["errors"]["name"][0]).to include "can't be blank"
      end
    end

    context "email がないとき" do
      let(:params) { attributes_for(:user, email: nil) }

      it "新規登録できない" do
        expect { subject }.to not_change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(422)
        expect(res["errors"]["email"][0]).to include "can't be blank"
      end
    end

    context "password がないとき" do
      let(:params) { attributes_for(:user, password: nil) }

      it "新規登録できない" do
        expect { subject }.to not_change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(422)
        expect(res["errors"]["password"][0]).to include "can't be blank"
      end
    end

    context "保存されたメールアドレスが指定されたとき" do
      let!(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email) }

      it "エラーする" do
        expect { subject }.to not_change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(422)
        expect(res["errors"]["email"][0]).to include "has already been taken"
      end
    end
  end

  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    let(:current_user) { create(:user) }

    context "email, password が正しいとき" do
      let(:params) { { email: current_user.email, password: current_user.password } }

      it "ログインできる" do
        subject
        res = response.header
        expect(res["access-token"]).to be_present
        expect(res["client"]).to be_present
        expect(res["uid"]).to be_present
        expect(response).to have_http_status(200)
      end
    end

    context "email が正しくないとき" do
      let(:params) { { email: "email", password: current_user.password } }

      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        expect(response.header["uid"]).to be_blank
        expect(response.header["access-token"]).to be_blank
        expect(response.header["client"]).to be_blank
        expect(response).to have_http_status(401)
      end
    end

    context "password が正しくないとき" do
      let(:params) { { email: current_user.email, password: "password" } }

      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        expect(response.header["uid"]).to be_blank
        expect(response.header["access-token"]).to be_blank
        expect(response.header["client"]).to be_blank
        expect(response).to have_http_status(401)
      end
    end
  end
end
