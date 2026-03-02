class RenameReturnsToReturnItems < ActiveRecord::Migration[7.0]
  def change
    rename_table :returns, :return_items
  end
end
