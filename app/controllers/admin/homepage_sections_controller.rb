class Admin::HomepageSectionsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_section, only: [:edit, :update]

  def index
    # ensure the main sections exist
    @sections = %w[
      new_arrivals
      exclusive_deals
      catalog_stats
      free_shipping
      guarantee_label
      footer_blurb
      footer_trust_line
      footer_newsletter_heading
      footer_newsletter_subheading
      footer_privacy_label
      footer_terms_label
    ].map { |id| HomepageSection.find_or_create(id) }
  end

  def edit
  end

  def update
    if @section.update(homepage_section_params)
      redirect_to admin_homepage_sections_path, notice: "Section updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_section
    @section = HomepageSection.find(params[:id])
  end

  def homepage_section_params
    params.require(:homepage_section).permit(:label, :headline, :description, :link_text, :link_url, :image)
  end
end
