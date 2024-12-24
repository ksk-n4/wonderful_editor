class CreateArticleLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :article_likes do |t|

      t.timestamps
    end
  end
end
