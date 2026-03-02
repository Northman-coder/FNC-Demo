Rails.application.configure do
  config.content_security_policy do |policy|
    # Default: only allow content from same origin
    policy.default_src :self

    # Scripts: self + inline (needed for Turbo/Stimulus and view inline scripts)
    # PayPal Smart Buttons loads scripts from paypal.com/paypalobjects.com.
    policy.script_src  :self, :unsafe_inline,
              "https://www.paypal.com", "https://www.sandbox.paypal.com",
              "https://www.paypalobjects.com",
              "https://*.paypal.com", "https://*.paypalobjects.com"

    # Styles: self + inline (needed for Tailwind and inline style attributes)
    policy.style_src   :self, :unsafe_inline

    # Images: self, data URIs (used in CSS), blob (Active Storage variants), and PayPal assets.
    policy.img_src     :self, :data, :blob,
          "https://www.paypalobjects.com",
          "https://*.paypalobjects.com"

    # Fonts: self only (SparklingValentine.ttf served locally)
    policy.font_src    :self, :data

    # Video/audio: self and blob (hero videos served from asset pipeline)
    policy.media_src   :self, :blob

    # XHR/fetch: Turbo uses same-origin requests. PayPal Smart Buttons also needs PayPal endpoints.
    policy.connect_src :self,
              "https://www.paypal.com", "https://www.sandbox.paypal.com",
              "https://api-m.paypal.com", "https://api-m.sandbox.paypal.com",
              "https://www.paypalobjects.com",
              "https://*.paypal.com", "https://*.paypalobjects.com"

    # PayPal renders its approval flow in iframes.
    policy.frame_src :self, "https://www.paypal.com", "https://www.sandbox.paypal.com", "https://*.paypal.com"

    # Completely block browser plugins (Flash, etc.)
    policy.object_src  :none

    # Block <base> tag hijacking
    policy.base_uri    :self

    # Block form submissions to external origins (allow PayPal checkout flows if they use form posts)
    policy.form_action :self, "https://www.paypal.com", "https://www.sandbox.paypal.com", "https://*.paypal.com"

    # Prevent this site from being embedded in iframes (clickjacking protection)
    policy.frame_ancestors :none
  end
end
