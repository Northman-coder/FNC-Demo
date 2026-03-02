class CreateContactDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_details do |t|
      t.text   :address
      t.string :email
      t.string :phone
      t.text   :hours

      t.timestamps
    end
  end
end
