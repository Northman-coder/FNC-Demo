class Admin::TaxSettingsController < ApplicationController
  before_action :authenticate_admin!

  def update
    tax_setting = TaxSetting.current

    if tax_setting.update(tax_setting_params)
      redirect_to admin_dashboard_path, notice: "VAT settings updated."
    else
      redirect_to admin_dashboard_path, alert: tax_setting.errors.full_messages.to_sentence
    end
  end

  private

  def tax_setting_params
    params.require(:tax_setting).permit(:uk_percent, :us_percent, :europe_percent, :international_percent)
  end
end
