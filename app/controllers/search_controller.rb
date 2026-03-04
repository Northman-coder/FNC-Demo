class SearchController < ApplicationController
  def typeahead
    query = params[:q].to_s.strip.first(80)

    if query.blank?
      return render json: { query: query, results: [], facets: { categories: {}, brands: {} } }
    end

    hits = Product
      .where("name ILIKE :q OR brand ILIKE :q", q: "%#{query}%")
      .order(Arel.sql("LOWER(name) ASC"))
      .limit(10)
      .select(:id, :name, :brand, :price, :category)

    facets = {
      categories: hits.group_by(&:category).transform_values(&:count),
      brands: hits.group_by(&:brand).transform_values(&:count)
    }

    render json: {
      query: query,
      results: hits.map { |p| { id: p.id, name: p.name, brand: p.brand, price: p.price, category: p.category } },
      facets: facets
    }
  end
end
