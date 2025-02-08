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
end
