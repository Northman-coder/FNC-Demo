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

  # Catalog bootstrap (idempotent)
  categories = [
    "Light Bulbs",
    "Computers & Hardware",
    "Home Audio",
    "Smart Home",
    "Cameras",
    "Kitchen",
    "Outdoor",
    "Accessories"
  ]

  categories.each do |name|
    Category.find_or_create_by!(name: name)
  end

  products = [
    {
      name: "LED Desk Lamp",
      price: 39.99,
      original_price: 59.99,
      category: "Light Bulbs",
      brand: "Lumina",
      new_arrival: true,
      description: "Adjustable LED lamp with touch dimmer and USB-C charging."
    },
    {
      name: "Wireless Mechanical Keyboard",
      price: 129.00,
      original_price: 169.00,
      category: "Computers & Hardware",
      brand: "Keywave",
      new_arrival: true,
      description: "Hot-swap keys, tri-mode wireless, and RGB backlight."
    },
    {
      name: "Bluetooth Soundbar",
      price: 199.00,
      original_price: 249.00,
      category: "Home Audio",
      brand: "Auralink",
      description: "2.1 channel bar with wireless subwoofer and HDMI ARC."
    },
    {
      name: "Smart Plug (4-pack)",
      price: 49.00,
      category: "Smart Home",
      brand: "Nestio",
      description: "App + voice control, energy monitoring, schedules, and scenes."
    },
    {
      name: "4K Action Camera",
      price: 249.00,
      original_price: 299.00,
      category: "Cameras",
      brand: "TrailCam",
      description: "Waterproof 4K60 action cam with stabilization and dual screens."
    },
    {
      name: "Enamel Dutch Oven 5.5qt",
      price: 119.00,
      category: "Kitchen",
      brand: "Hearthstone",
      description: "Cast iron with enamel finish for braise, bake, or roast."
    }
  ]

  products.each do |attrs|
    product = Product.find_or_create_by!(name: attrs[:name]) do |p|
      p.price = attrs[:price]
      p.original_price = attrs[:original_price]
      p.category = attrs[:category]
      p.brand = attrs[:brand]
      p.new_arrival = attrs[:new_arrival] || false
    end

    product.update!(description: attrs[:description]) if attrs[:description].present?
  end
