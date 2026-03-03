# frozen_string_literal: true

module Ai
  class ProductSearch
    DEFAULT_LIMIT = 5

    def initialize(limit: DEFAULT_LIMIT)
      @limit = limit
    end

    def search(query)
      return Product.none if query.blank?

      Product
        .left_joins(:rich_text_description)
        .where("products.name ILIKE :q OR products.brand ILIKE :q OR action_text_rich_texts.body ILIKE :q", q: "%#{sanitize(query)}%")
        .order(new_arrival: :desc, created_at: :desc)
        .limit(@limit)
    end

    private

    def sanitize(text)
      text.to_s.gsub(/[%_]/, "")
    end
  end
end
