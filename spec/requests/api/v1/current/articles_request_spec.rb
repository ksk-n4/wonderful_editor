require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "複数の記事が存在するとき" do
      let!(:a_article) { create(:article, :published, user: current_user, updated_at: 1.days.ago) }
      let!(:b_article) { create(:article, :published, user: current_user, updated_at: 3.days.ago) }
      let!(:c_article) { create(:article, :published, user: current_user) }

      before do
        create(:article, :draft, user: current_user)
        create(:article, :published)
      end

      it "自分の書いた公開記事の一覧のみが取得できる(更新順)" do
        subject
        res = JSON.parse(response.body)

        expect(res.length).to eq 3
        expect(res.map {|article| article["id"] }).to eq [c_article.id, a_article.id, b_article.id]
        expect(res[0]["user"]["id"]).to eq current_user.id
        expect(res[0]["user"]["name"]).to eq current_user.name
        expect(res[0]["user"]["email"]).to eq current_user.email
        expect(response).to have_http_status(200)
      end
    end
  end
end
