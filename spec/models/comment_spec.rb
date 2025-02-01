# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_article_id  (article_id)
#  index_comments_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Comment, type: :model do
  let!(:user) { build(:user) }
  let!(:article) { build(:article, title: "テスト", body: "テスト", user: user) }

  context "必要な情報が揃っている場合" do
    let(:comment) { build(:comment, body: "テスト", user: user, article: article) }

    it "コメント投稿できる" do
      expect(comment).to be_valid
    end
  end

  context "body がない場合" do
    let(:comment) { build(:comment, body: nil, user: user, article: article) }

    it "エラーが発生する" do
      expect(comment).not_to be_valid
    end
  end
end
