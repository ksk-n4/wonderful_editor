require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:a_article) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:b_article) { create(:article, :published, updated_at: 3.days.ago) }
    let!(:c_article) { create(:article, :published) }

    before { create(:article, :draft) }

    it "公開中の記事の一覧が取得できる" do
      subject
      res = JSON.parse(response.body)

      expect(res.length).to eq 3
      expect(res.map {|article| article["id"] }).to eq([c_article.id, a_article.id, b_article.id])
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在するとき" do
      let(:article_id) { article.id }

      context "対象の記事が公開中の場合" do
        let(:article) { create(:article, :published) }

        it "任意の記事が取得できる" do
          subject
          res = JSON.parse(response.body)
          expect(response).to have_http_status(200)

          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
        end
      end

      context "対象の記事が下書き状態の場合" do
        let(:article) { create(:article, :draft) }

        it "記事が見つからない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
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
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "公開指定で記事を作成するとき" do
      let(:params) { { article: attributes_for(:article, :published) } }

      it "記事が作成できる" do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(200)
      end
    end

    context "下書き指定で記事を作成するとき" do
      let(:params) { { article: attributes_for(:article, :draft) } }

      it "下書き記事が作成できる" do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "draft"
        expect(response).to have_http_status(200)
      end
    end

    context "不適切なパラメータを送信したとき" do
      let(:params) { { article: attributes_for(:article, status: "foo") } }

      it "エラーする" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe "PATCH(PUT) /articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article, :published) } }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分の記事を更新するとき" do
      let(:article) { create(:article, :draft, user: current_user) }

      it "更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status].to_s)
        expect(response).to have_http_status(200)
      end
    end

    context "他のユーザーの記事を更新しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article.id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分が所持している記事を削除しようとするとき" do
      let!(:article) { create(:article, user: current_user) }

      it "削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(204)
      end
    end

    context "自分が所持していない記事を削除しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              not_change { Article.count }
      end
    end
  end
end
