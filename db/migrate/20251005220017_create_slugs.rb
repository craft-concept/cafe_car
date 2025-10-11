class CreateSlugs < ActiveRecord::Migration[8.0]
  def change
    create_table :slugs do |t|
      t.string     :slug, null: false
      t.references :sluggable, polymorphic: true
      t.string     :scope
      t.datetime   :created_at
    end

    add_index :slugs, [:slug, :sluggable_type]
    add_index :slugs, [:slug, :sluggable_type, :scope], unique: true
  end
end
