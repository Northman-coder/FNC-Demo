class CreateSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :subscribers do |t|
      t.string :email, null: false
      t.string :name
      t.string :unsubscribe_token, null: false
      t.timestamps
    end

    add_index :subscribers, :email, unique: true
    add_index :subscribers, :unsubscribe_token, unique: true
  end
end
