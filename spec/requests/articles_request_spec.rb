require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    before { create_list(:article, 3) }

    it "記事の一覧が取得できる" do
      subject
      res = JSON.parse(response.body)

      expect(res.length).to eq 3
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在するとき" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }

      it "記事のレコードが取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(200)

        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["content"]).to eq article.content
        expect(res["updated_at"]).to eq article.updated_at.strftime("%Y-%m-%dT%H:%M:%S.%3NZ")
        expect(res["user"]["id"]).to eq article.user.id
      end
    end

    context "指定した id の記事が存在しないとき" do
      let(:article_id) { 10000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params) }

    context "適切なパラメーターを送信したとき" do
      let(:params) { { article: attributes_for(:article) } }
      let(:current_user) { create(:user) }

      before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

      it "記事が作成できる" do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["content"]).to eq params[:article][:content]
        expect(response).to have_http_status(200)
      end
    end
  end

end
