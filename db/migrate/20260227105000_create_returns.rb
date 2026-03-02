class CreateReturns < ActiveRecord::Migration[7.0]
  def change
    create_table :returns do |t|
      t.references :order_item, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.string :reason
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
  end
end
