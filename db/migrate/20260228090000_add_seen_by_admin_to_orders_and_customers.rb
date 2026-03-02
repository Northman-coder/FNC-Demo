class AddSeenByAdminToOrdersAndCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :seen_by_admin, :boolean, null: false, default: false
    add_index :orders, :seen_by_admin

    add_column :customers, :seen_by_admin, :boolean, null: false, default: false
    add_index :customers, :seen_by_admin
  end
end
