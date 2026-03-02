class SubscribersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: []

  def create
    email = params[:email].to_s.strip.downcase.first(254)
    name  = params[:name].to_s.strip.first(100)

    if email.blank?
      redirect_back fallback_location: root_path, alert: "Please enter an email address."
      return
    end

    unless Subscriber.exists?(email: email)
      Subscriber.create!(email: email, name: name.presence)
    end

    redirect_back fallback_location: root_path, notice: "You're subscribed!"
  end

  def unsubscribe
    @subscriber = Subscriber.find_by(unsubscribe_token: params[:token])
    if @subscriber
      @subscriber.destroy
    end
    # render unsubscribe view regardless (success or already gone)
  end
end
