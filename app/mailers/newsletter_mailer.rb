class NewsletterMailer < ApplicationMailer
  def broadcast(subscriber, subject, body_html)
    @subscriber  = subscriber
    @body_html   = body_html
    @store_name  = ENV.fetch("STORE_NAME", "Our Store")
    mail(
      to: subscriber.email,
      subject: subject
    )
  end
end
