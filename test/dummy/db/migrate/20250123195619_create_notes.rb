# Generated via `rails cafe_car:notes`
class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.references :notable, polymorphic: true, null: false
      t.references :author, null: false, foreign_key: {to_table: :users}
      t.text :body

      t.timestamps
    end
  end
end
