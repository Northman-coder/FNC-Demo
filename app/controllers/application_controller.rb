class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :validate_customer_session

  protected

  def validate_customer_session
    if customer_signed_in? && !current_customer.is_a?(Customer)
      sign_out(:customer)
    end
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      admin_dashboard_path
    else
      root_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone, :address, :city, :postal_code, :country
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :phone, :address, :city, :postal_code, :country
    ])
  end

  private

  def catalog_only_mode?
    Rails.configuration.x.catalog_only_mode == true
  end

  def ensure_catalog_open!
    return unless catalog_only_mode?
    return if admin_signed_in?

    redirect_back fallback_location: root_path, alert: "Store is currently in catalog-only mode."
  end
end

