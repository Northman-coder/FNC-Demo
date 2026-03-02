class Customers::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        sign_in(:customer, resource)
        redirect_to root_path, notice: "Welcome, #{resource.first_name}! Your account was created." and return
      end
    end
  end

  private

  def sign_up_params
    params.require(:customer).permit(
      :first_name, :last_name, :email, :phone,
      :address, :city, :postal_code, :country,
      :password, :password_confirmation
    )
  end

  def account_update_params
    params.require(:customer).permit(
      :first_name, :last_name, :email, :phone,
      :address, :city, :postal_code, :country,
      :password, :password_confirmation, :current_password
    )
  end
end
