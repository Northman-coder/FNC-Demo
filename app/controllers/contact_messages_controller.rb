class ContactMessagesController < ApplicationController
  before_action :ensure_catalog_open!, only: [:create]

  def create
    @message = ContactMessage.new(message_params)
    if @message.save
      redirect_to contact_path, notice: "Your message has been sent! We will get back to you soon."
    else
      @contact_detail = ContactDetail.instance
      render "pages/contact", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
