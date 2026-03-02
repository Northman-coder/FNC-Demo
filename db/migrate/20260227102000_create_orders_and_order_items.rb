class CreateOrdersAndOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
