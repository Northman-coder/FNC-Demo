class CategoriesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_category, only: %i[edit update destroy purge_image]

  def index
    @categories = Category.all.order(:name)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: "Category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy!
    redirect_to categories_path, notice: "Category was successfully deleted."
  end

  def purge_image
    @category.image.purge
    redirect_to edit_category_path(@category), notice: "Image removed."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.expect(category: [ :name, :image ])
  end
end
