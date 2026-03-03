# frozen_string_literal: true

require "net/http"
require "json"

module Ai
  class Assistant
    MODEL_ENV_KEY = "AI_MODEL"
    API_KEY_ENV_KEY = "OPENAI_API_KEY"
    DEFAULT_MODEL = "gpt-4o-mini"

    def initialize(message:)
      @message = message.to_s.strip
    end

    def call
      products = ProductSearch.new.search(@message)
      ai_text = generate_reply(@message, products)

      {
        message: ai_text,
        products: serialize_products(products)
      }
    end

    private

    def generate_reply(message, products)
      return fallback_reply(products) if api_key.blank?

      prompt = build_prompt(products)
      body = {
        model: ENV.fetch(MODEL_ENV_KEY, DEFAULT_MODEL),
        temperature: 0.4,
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: message },
          { role: "system", content: prompt }
        ]
      }

      uri = URI("https://api.openai.com/v1/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body.to_json

      response = http.request(request)
      parsed = JSON.parse(response.body)
      parsed.dig("choices", 0, "message", "content") || fallback_reply(products)
    rescue StandardError => e
      Rails.logger.warn("AI assistant fallback: #{e.class} #{e.message}")
      fallback_reply(products)
    end

    def build_prompt(products)
      summary = products.map do |product|
        "- ##{product.id}: #{product.name} (#{format_price(product.price)}) | brand: #{product.brand}"
      end.join("\n")

      <<~PROMPT
      You are a concise shopping assistant. Recommend up to #{ProductSearch::DEFAULT_LIMIT} items from the list below and stay brief.
      Mention price and brand. Link using the provided paths only.
      Inventory:
      #{summary.presence || "(no matches found)"}
      PROMPT
    end

    def fallback_reply(products)
      return "I could not find matching items, but you can browse the catalog." if products.blank?

      names = products.limit(3).map(&:name)
      "Here are some options: #{names.join(", ")}."
    end

    def serialize_products(products)
      routes = Rails.application.routes.url_helpers

      products.map do |product|
        {
          id: product.id,
          name: product.name,
          price: product.price,
          brand: product.brand,
          path: routes.product_path(product, only_path: true),
          image_path: image_path_for(product, routes)
        }
      end
    end

    def image_path_for(product, routes)
      return unless product.image&.attached?

      routes.rails_blob_path(product.image, only_path: true)
    rescue StandardError
      nil
    end

    def system_prompt
      "Always be helpful and concise. Use bullets rarely. Keep replies under 70 words."
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}"
      }
    end

    def api_key
      ENV[API_KEY_ENV_KEY]
    end

    def format_price(price)
      return "N/A" unless price

      "$#{price}"
    end
  end
end
