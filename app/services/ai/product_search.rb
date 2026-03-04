# frozen_string_literal: true

module Ai
  class ProductSearch
    DEFAULT_LIMIT = 5

    def initialize(limit: DEFAULT_LIMIT)
      @limit = limit
    end

    def search(query)
      q = query.to_s
      return new_arrivals if greeting?(q)

      scope = Product.left_joins(:rich_text_description)

      if q.present?
        cleaned = sanitize(q)
        scope = scope.where(
          "products.name ILIKE :q OR products.brand ILIKE :q OR action_text_rich_texts.body ILIKE :q",
          q: "%#{cleaned}%"
        )
      end

      max_price = extract_max_price(q)
      scope = scope.where("products.price <= ?", max_price) if max_price

      scope = scope.discounted if deals?(q)
      scope = scope.new_arrivals if new_arrivals?(q)

      scope = scope.order(price: :asc) if cheap?(q) || max_price
      scope = scope.order(new_arrival: :desc, trend_score: :desc, created_at: :desc) unless cheap?(q)

      results = scope.limit(@limit)
      return results if results.any?

      fallback_products
    end

    private

    def sanitize(text)
      text.to_s.gsub(/[%_]/, "")
    end

    def cheap?(text)
      text.match?(/cheap|cheapest|budget|low price|lowest|inexpensive/i)
    end

    def deals?(text)
      text.match?(/deal|offer|sale|discount/i)
    end

    def new_arrivals?(text)
      text.match?(/new arrival|new drop|just in|latest/i)
    end

    def greeting?(text)
      text.strip.match?(/^(hi|hello|hey|yo|hola)\b/i)
    end

    def extract_max_price(text)
      # e.g., "under $50", "below 100", "< 75"
      if (m = text.match(/(?:under|below|less than|<)\s*\$?(\d+(?:\.\d+)?)/i))
        m[1].to_f
      end
    end

    def new_arrivals
      Product.new_arrivals.order(created_at: :desc).limit(@limit)
    end

    def fallback_products
      discounted = Product.discounted.order(Arel.sql("original_price - price DESC NULLS LAST"))
      return discounted.limit(@limit) if discounted.exists?

      new_arrivals_presence = new_arrivals
      return new_arrivals_presence if new_arrivals_presence.any?

      Product.order(trend_score: :desc, created_at: :desc).limit(@limit)
    end
  end
end
