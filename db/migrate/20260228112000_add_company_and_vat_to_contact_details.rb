class AddCompanyAndVatToContactDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :contact_details, :company_name, :string
    add_column :contact_details, :vat_number, :string
  end
end
