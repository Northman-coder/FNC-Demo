# frozen_string_literal: true

ActiveAdmin.register Product do
  permit_params :name, :brand, :category, :price, :original_price, :dimensions, :new_arrival

  index do
    selectable_column
    id_column
    column :name
    column :brand
    column :category
    column :price
    column :original_price
    column :new_arrival
    column :created_at
    actions
  end

  filter :name
  filter :brand
  filter :category
  filter :new_arrival
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :brand
      f.input :category
      f.input :price
      f.input :original_price
      f.input :dimensions
      f.input :new_arrival
    end
    f.actions
  end
end
