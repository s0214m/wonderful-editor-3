class Api::V1::Articles::DraftsController < Api::V1::BaseApiController
  def index
    articles = current_user.articles.preload(:user).draft.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = current_user.articles.draft.find(params[:id])
    render json: article, serializer: Api::V1::ArticleSerializer
  end
end
