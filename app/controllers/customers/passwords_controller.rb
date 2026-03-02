class Customers::PasswordsController < Devise::PasswordsController
  # Override edit (GET) to validate the token before showing the form.
  # Devise only validates on PUT by default, so an already-used link
  # would still render the form without this check.
  def edit
    token = params[:reset_password_token].to_s

    if token.blank?
      redirect_to new_customer_password_path, alert: "Invalid password reset link."
      return
    end

    # Derive the stored digest and look up the customer
    token_digest = Devise.token_generator.digest(Customer, :reset_password_token, token)
    customer = Customer.find_by(reset_password_token: token_digest)

    if customer.nil?
      redirect_to new_customer_password_path,
        alert: "This password reset link is invalid or has already been used. Please request a new one."
      return
    end

    unless customer.reset_password_period_valid?
      redirect_to new_customer_password_path,
        alert: "This password reset link has expired. Please request a new one."
      return
    end

    super
  end
end
