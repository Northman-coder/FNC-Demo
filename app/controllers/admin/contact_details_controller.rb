class Admin::ContactDetailsController < ApplicationController
  before_action :authenticate_admin!

  def edit
    @contact_detail = ContactDetail.instance
  end

  def update
    @contact_detail = ContactDetail.instance
    if @contact_detail.update(contact_detail_params)
      redirect_to admin_dashboard_path, notice: "Contact details updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def contact_detail_params
    params.require(:contact_detail).permit(:company_name, :vat_number, :address, :email, :phone, :hours)
  end
end
