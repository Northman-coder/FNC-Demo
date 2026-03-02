class PagesController < ApplicationController
  def about
  end

  def contact
    @contact_detail = ContactDetail.first_or_initialize
    @message = ContactMessage.new
  end

  def cookies
  end
end