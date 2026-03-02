class AddDimensionsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :dimensions, :string
  end
end
