# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  content    :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  let!(:user) { build(:user) }

  context "必要な情報が揃っている場合" do
    let(:article) { build(:article, title: "テスト", content: "テスト", user: user) }

    it "記事が作成される" do
      expect(article).to be_valid
    end
  end

  context "タイトルがないとき" do
    let(:article) { build(:article, title: nil, user: user) }

    it "エラーが発生する" do
      expect(article).not_to be_valid
    end
  end
end
