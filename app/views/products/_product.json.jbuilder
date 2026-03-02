json.extract! product, :id, :name, :price, :created_at, :updated_at
json.url product_url(product, format: :json)
json.description product.description.to_s
json.image do
  if product.image.attached?
    json.array!([product.image]) do |img|
      json.id img.id
      json.url url_for(img)
    end
  else
    json.array!([])
  end
end
