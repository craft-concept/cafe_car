class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.references :author, index: true, foreign_key: {to_table: :users}
      t.string :title, null: false
      t.text :body
      t.datetime :published_at

      t.timestamps
    end
  end
end
