class CreateAccounting < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.references :owner, foreign_key: {to_table: :users}
      t.string :name
      t.timestamps
    end

    create_table :invoices do |t|
      t.references :sender, foreign_key: {to_table: :users}
      t.references :client, foreign_key: true
      t.decimal :total, precision: 12, scale: 2
      t.date :due_on
      t.date :issued_on
      t.text :note
      t.timestamps
    end

    create_table :line_items do |t|
      t.references :invoice, foreign_key: true
      t.decimal :price, precision: 12, scale: 2
      t.integer :quantity
      t.text :description
      t.timestamps
    end


    create_table :payments do |t|
      t.references :invoice, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2
      t.datetime :paid_at
      t.text :note
      t.timestamps
    end
  end
end
