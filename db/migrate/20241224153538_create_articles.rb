class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.references :user, null: false, forien_key: true
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
