class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false, default: "Title"
      t.text :body, null: false, default: "Content"
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
