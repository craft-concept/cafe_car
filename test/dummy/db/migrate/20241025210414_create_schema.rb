class CreateSchema < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest
      t.timestamps
    end

    create_table :articles do |t|
      t.references :author, index: true, foreign_key: {to_table: :users}
      t.string     :title, null: false
      # t.string     :slug, null: false, index: {unique: true}
      t.datetime   :published_at
      t.text       :summary
      # action_text :body
      t.timestamps
    end
  end
end
