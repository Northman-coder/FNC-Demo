# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# create default homepage sections so they exist for editing
[{
  identifier: "new_arrivals",
  label: "New This Season",
  headline: "Latest Arrivals\nJust Landed",
  link_text: "Shop New Arrivals",
  link_url: "/products"
}, {
  identifier: "exclusive_deals",
  label: "Limited Time Offers",
  headline: "Exclusive Deals\n& Discounts",
  link_text: "View All Offers",
  link_url: "/products"
}, {
  identifier: "catalog_stats",
  description: "500+ Products &bull; 50+ Brands"
}].each do |attrs|
  HomepageSection.find_or_create_by(identifier: attrs[:identifier]) do |sec|
    sec.assign_attributes(attrs)
  end
end
