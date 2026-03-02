require "net/http"
require "uri"

module Payments
  class PaypalClient
    class ConfigurationError < StandardError; end
    class RequestError < StandardError; end

    def self.from_env
      client_id = ENV["PAYPAL_CLIENT_ID"].to_s
      client_secret = ENV["PAYPAL_CLIENT_SECRET"].to_s
      env = ENV.fetch("PAYPAL_ENV", "sandbox").to_s

      raise ConfigurationError, "PayPal is not configured (missing PAYPAL_CLIENT_ID)." if client_id.blank?
      raise ConfigurationError, "PayPal is not configured (missing PAYPAL_CLIENT_SECRET)." if client_secret.blank?

      api_base_url = case env
                     when "live", "production" then "https://api-m.paypal.com"
                     else "https://api-m.sandbox.paypal.com"
                     end

      new(api_base_url:, client_id:, client_secret:)
    end

    def initialize(api_base_url:, client_id:, client_secret:, currency: ENV.fetch("PAYMENT_CURRENCY", "GBP"))
      @api_base_url = api_base_url
      @client_id = client_id
      @client_secret = client_secret
      @currency = currency.to_s.upcase
    end

    def create_order(order:, return_url: nil, cancel_url: nil)
      access_token = fetch_access_token!

      body = {
        intent: "CAPTURE",
        purchase_units: [
          {
            reference_id: order.id.to_s,
            amount: {
              currency_code: @currency,
              value: format("%.2f", order.total_with_tax.to_d)
            }
          }
        ],
        application_context: {
          user_action: "PAY_NOW",
          landing_page: "LOGIN"
        }
      }

      if return_url.present? && cancel_url.present?
        body[:application_context][:return_url] = return_url
        body[:application_context][:cancel_url] = cancel_url
      end

      res = request_json!(
        method: :post,
        path: "/v2/checkout/orders",
        access_token: access_token,
        body: body
      )

      paypal_order_id = res.fetch("id")
      approve = res.fetch("links").find { |l| l["rel"] == "approve" }
      approve_url = approve && approve["href"]

      if return_url.present? && cancel_url.present? && approve_url.blank?
        raise RequestError, "Missing approval URL from PayPal"
      end

      result = { paypal_order_id: paypal_order_id }
      result[:approve_url] = approve_url if approve_url.present?
      result
    end

    def capture_order(paypal_order_id)
      access_token = fetch_access_token!

      request_json!(
        method: :post,
        path: "/v2/checkout/orders/#{paypal_order_id}/capture",
        access_token: access_token,
        body: {}
      )
    end

    private

    def fetch_access_token!
      uri = URI.join(@api_base_url, "/v1/oauth2/token")
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(@client_id, @client_secret)
      req["Accept"] = "application/json"
      req.set_form_data({ "grant_type" => "client_credentials" })

      res = perform_request(uri, req)

      json = parse_json(res)
      json.fetch("access_token")
    rescue KeyError
      raise RequestError, "PayPal auth failed"
    end

    def request_json!(method:, path:, access_token:, body:)
      uri = URI.join(@api_base_url, path)

      req = case method
            when :post then Net::HTTP::Post.new(uri)
            when :get then Net::HTTP::Get.new(uri)
            else raise ArgumentError, "Unsupported method"
            end

      req["Authorization"] = "Bearer #{access_token}"
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req.body = JSON.generate(body)

      res = perform_request(uri, req)
      json = parse_json(res)

      unless res.is_a?(Net::HTTPSuccess)
        message = json["message"] || json.dig("details", 0, "description") || res.message
        raise RequestError, message
      end

      json
    end

    def perform_request(uri, req)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(req)
      end
    end

    def parse_json(res)
      JSON.parse(res.body.to_s)
    rescue JSON::ParserError
      raise RequestError, "Invalid JSON from PayPal"
    end
  end
end
