class AddOriginalPriceToProducts < ActiveRecord::Migration[8.1]
  def change
    # original_price column already exists in the schema.  This migration is
    # recorded to keep schema_migrations in sync; no changes are required.
    # If you remove the column later, add the appropriate code here.
    unless column_exists?(:products, :original_price)
      add_column :products, :original_price, :decimal
    end
  end
end
