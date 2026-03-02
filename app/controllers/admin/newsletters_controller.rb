class Admin::NewslettersController < ApplicationController
  before_action :authenticate_admin!

  def new
    @subscriber_count = Subscriber.count
  end

  def create
    subject   = params[:subject].to_s.strip
    body_html = params[:body].to_s.strip

    if subject.blank? || body_html.blank?
      flash.now[:alert] = "Subject and body are required."
      @subscriber_count = Subscriber.count
      render :new, status: :unprocessable_entity
      return
    end

    Subscriber.find_each do |subscriber|
      NewsletterMailer.broadcast(subscriber, subject, body_html).deliver_later
    end

    redirect_to admin_root_path, notice: "Newsletter queued for #{Subscriber.count} subscriber(s)."
  end
end
