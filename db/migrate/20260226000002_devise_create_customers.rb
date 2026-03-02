class DeviseCreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Custom fields
      t.string :first_name, null: false, default: ""
      t.string :last_name,  null: false, default: ""
      t.string :phone
      t.string :address
      t.string :city
      t.string :postal_code
      t.string :country

      t.timestamps null: false
    end

    add_index :customers, :email,                unique: true
    add_index :customers, :reset_password_token, unique: true
  end
end
