class AddStatusToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :status, :integer, null: false, default: 0
  end
end
