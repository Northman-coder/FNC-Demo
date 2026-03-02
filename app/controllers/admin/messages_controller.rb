class Admin::MessagesController < ApplicationController
  before_action :authenticate_admin!

  def index
    @messages = ContactMessage.order(created_at: :desc)
  end

  def show
    @message = ContactMessage.find(params[:id])
    @message.mark_read!
  end

  def destroy
    @message = ContactMessage.find(params[:id])
    @message.destroy
    redirect_to admin_messages_path, notice: "Message deleted successfully."
  end
end