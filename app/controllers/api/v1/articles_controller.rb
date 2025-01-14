module Api::V1
  class ArticlesController < BaseApiController
    def index
      articles = Article.all.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.find(params[:id])
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def create
      article = current_user.articles.new(article_params)
      article.save!

      render json: article, serializer: Api::V1::ArticleSerializer
    end

    private

      def article_params
        params.require(:article).permit(:title, :content)
      end
  end
end
