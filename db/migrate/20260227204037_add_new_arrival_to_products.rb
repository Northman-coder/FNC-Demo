class AddNewArrivalToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :new_arrival, :boolean, default: false, null: false
    add_index :products, :new_arrival
  end
end
