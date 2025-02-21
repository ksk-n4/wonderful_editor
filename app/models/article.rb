# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :integer          default("draft")
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :article_likes, dependent: :destroy

  validates :title, presence: true

  enum status: { draft: 0, published: 1 }

  scope :published, -> { where(status: :published) }
end
