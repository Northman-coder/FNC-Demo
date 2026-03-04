class ProductsController < ApplicationController
  before_action :authenticate_admin!, only: %i[new create edit update destroy toggle_new_arrival]
  before_action :set_product, only: %i[ show edit update destroy toggle_new_arrival ]
  before_action :set_categories, only: %i[new edit create update]

  # GET /products or /products.json
  def index
    prepare_shared_lists

    query = params[:query].to_s.strip.first(100)
    has_sort = params[:sort].present?

    @title = "Search results" if query.present?

    @products = Product.all
    @products = @products.where("name ILIKE ?", "%#{query}%") if query.present?
    @products = @products.where(category: params[:category]) if params[:category].present?
    @products = @products.where(brand: params[:brand]) if params[:brand].present?

    min_price = safe_decimal(params[:price_min])
    max_price = safe_decimal(params[:price_max])
    @products = @products.where("price >= ?", min_price) if min_price
    @products = @products.where("price <= ?", max_price) if max_price
    @products = @products.in_stock if truthy_param?(:in_stock)
    @products = @products.discounted if truthy_param?(:discounted)

    filters_applied = filters_present?(query, has_sort)
    @filtered_listing = filters_applied

    @title ||= params[:category] if params[:category].present?
    @title ||= params[:brand] if params[:brand].present?
    @title ||= "All products" if filters_applied

    unless filters_applied
      @products = @products.where.not(id: @recommendations.pluck(:id))
      @products = @products.where.not(id: @new_arrivals.pluck(:id))
    end

    @products = apply_sort(@products)
    @facets = build_facets(@products)
    @pagy, @products = pagy(@products, items: pagy_items_for_grid)
  end

  # GET /products/1 or /products/1.json
  #def show
  #end
  def show
    @product = Product.find(params[:id])
    @related_products = @product.related_or_fallback(limit: 8)
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /new-arrivals
  def new_arrivals
    prepare_shared_lists
    @filtered_listing = true
    @products = apply_sort(Product.new_arrivals)
    @pagy, @products = pagy(@products, items: pagy_items_for_grid)
    @title = "New Arrivals"
    render :index
  end

  # GET /exclusive-deals
  def exclusive_deals
    prepare_shared_lists
    @filtered_listing = true
    @products = apply_sort(Product.discounted)
    @pagy, @products = pagy(@products, items: pagy_items_for_grid)
    @title = "Exclusive Deals"
    render :index
  end

  # GET /brands
  def brands
    @brands = Product.where.not(brand: [nil, ""]).distinct.order(:brand).pluck(:brand)
  end

  # GET /brands/:brand
  def brand
    prepare_shared_lists
    @brand = params[:brand]
    @products = apply_sort(Product.where(brand: @brand))
    @pagy, @products = pagy(@products, items: pagy_items_for_grid)
    @title = @brand
    render :index
  end

  # PATCH /products/1/toggle_new_arrival
  def toggle_new_arrival
    # only admins may flip the flag
    @product.toggle_new_arrival!
    redirect_back fallback_location: products_path, notice: "Product designation updated."
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    # process removals before attempting update so that validations take them
    if params[:remove_images].present?
      params[:remove_images].each do |att_id|
        att = @product.images.find_by(id: att_id)
        att&.purge
      end
    end

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, notice: "Product was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    def pagy_items_for_grid
      # Homepage grid is lg:grid-cols-5; show 5 rows per page.
      25
    end

    def truthy_param?(key)
      ActiveModel::Type::Boolean.new.cast(params[key])
    end

    def safe_decimal(value)
      return nil if value.blank?

      BigDecimal(value.to_s)
    rescue ArgumentError
      nil
    end

    def filters_present?(query, has_sort)
      query.present? || params[:category].present? || params[:brand].present? || params[:price_min].present? ||
        params[:price_max].present? || truthy_param?(:discounted) || truthy_param?(:in_stock) || has_sort
    end

    def build_facets(scope)
      facet_scope = scope.unscope(:order)

      {
        categories: facet_scope.group(:category).order(Arel.sql("COUNT(*) DESC")).limit(10).count,
        brands: facet_scope.group(:brand).order(Arel.sql("COUNT(*) DESC")).limit(10).count,
        price_ranges: price_range_facets(facet_scope)
      }
    end

    def price_range_facets(scope)
      buckets = [[0, 50], [50, 100], [100, 200], [200, nil]]

      buckets.map do |min, max|
        bucket_scope = scope
        bucket_scope = bucket_scope.where("price >= ?", min) if min
        bucket_scope = bucket_scope.where("price < ?", max) if max

        label = max ? "$#{min}-#{max}" : "$#{min}+"
        [label, bucket_scope.count]
      end.to_h
    end

    def prepare_shared_lists
      # show first three rows of categories on homepage (9 items) and make tiles larger
      featured_names = ["Light Bulbs", "Computers & Hardware"]
      featured_case = featured_names.each_with_index.map do |name, idx|
        "WHEN LOWER(categories.name) = LOWER(#{ActiveRecord::Base.connection.quote(name)}) THEN #{idx}"
      end.join(" ")

      @categories = Category
        .order(Arel.sql("CASE #{featured_case} ELSE 999 END ASC"))
        .order(:name)
        .limit(9)

      @sidebar_categories = Category.order(:name).pluck(:name)
      @recommendations = Product.discounted.limit(10)
      @new_arrivals = Product.new_arrivals.limit(10)
    end

    def apply_sort(scope)
      sort = params[:sort].to_s

      case sort
      when "price_asc"
        scope.order(price: :asc)
      when "price_desc"
        scope.order(price: :desc)
      when "name_asc"
        scope.order(Arel.sql("LOWER(products.name) ASC"))
      when "discount_desc"
        scope.order(Arel.sql("COALESCE(products.original_price - products.price, 0) DESC"))
      else
        # default: newest
        scope.order(created_at: :desc)
      end
    end

    def set_categories
      @categories = Category.order(:name).pluck(:name)
    end

    # Only allow a list of trusted parameters through.
    def product_params
      p = params.expect(product: [
        :name,
        :description,
        :price,
        :original_price,
        :category,
        :brand,
        :dimensions,
        :stock_level,
        :low_stock_threshold,
        :popularity_score,
        :trend_score,
        :image,
        images: []
      ])

      # Rails will pass an empty array for `images` when the file field has no
      # selection; assigning that array would clear existing attachments.
      # Drop the key entirely in that case so the update leaves them intact.
      if p[:images].is_a?(Array) && p[:images].all?(&:blank?)
        p.delete(:images)
      end

      p
    end
end
