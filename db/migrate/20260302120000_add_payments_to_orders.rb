class AddPaymentsToOrders < ActiveRecord::Migration[8.1]
  def change
    change_table :orders, bulk: true do |t|
      t.string :payment_provider
      t.datetime :paid_at

      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id

      t.string :paypal_order_id
    end

    add_index :orders, :stripe_checkout_session_id, unique: true
    add_index :orders, :paypal_order_id, unique: true
  end
end
