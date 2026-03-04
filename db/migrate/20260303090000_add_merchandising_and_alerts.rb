class AddMerchandisingAndAlerts < ActiveRecord::Migration[8.1]
  def change
    change_table :products, bulk: true do |t|
      t.integer :stock_level, null: false, default: 0
      t.integer :low_stock_threshold, null: false, default: 5
      t.integer :popularity_score, null: false, default: 0
      t.integer :trend_score, null: false, default: 0
    end

    add_index :products, :stock_level
    add_index :products, :trend_score

    create_table :product_relationships do |t|
      t.references :product, null: false, foreign_key: true
      t.references :related_product, null: false, foreign_key: { to_table: :products }
      t.string :kind, null: false, default: "related"
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :product_relationships, [:product_id, :related_product_id, :kind], unique: true, name: "index_product_relationships_on_pair_and_kind"

    create_table :stock_alerts do |t|
      t.references :product, null: false, foreign_key: true
      t.string :email
      t.string :phone
      t.string :token, null: false
      t.datetime :confirmed_at
      t.datetime :notified_at
      t.timestamps
    end
    add_index :stock_alerts, :token, unique: true
    add_index :stock_alerts, [:product_id, :email], name: "index_stock_alerts_on_product_and_email"

    create_table :price_alerts do |t|
      t.references :product, null: false, foreign_key: true
      t.string :email
      t.string :phone
      t.decimal :target_price, precision: 10, scale: 2
      t.string :token, null: false
      t.datetime :confirmed_at
      t.datetime :triggered_at
      t.timestamps
    end
    add_index :price_alerts, :token, unique: true
    add_index :price_alerts, [:product_id, :email], name: "index_price_alerts_on_product_and_email"
  end
end
