class AddPaidToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_column :invoices, :paid, :boolean, null: false, default: false
  end
end
