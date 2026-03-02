class CreateTaxSettingsAndAddTaxToOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_settings do |t|
      t.decimal :uk_percent, precision: 5, scale: 2, default: 20.0, null: false
      t.decimal :us_percent, precision: 5, scale: 2, default: 0.0, null: false
      t.decimal :europe_percent, precision: 5, scale: 2, default: 0.0, null: false
      t.decimal :international_percent, precision: 5, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_column :orders, :tax_region, :string
    add_column :orders, :tax_percent, :decimal, precision: 5, scale: 2, default: 0.0, null: false
    add_column :orders, :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
