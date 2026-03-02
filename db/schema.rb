# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_02_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_details", force: :cascade do |t|
    t.text "address"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.text "hours"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.string "vat_number"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.boolean "read", default: false, null: false
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "phone"
    t.string "postal_code"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "seen_by_admin", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
    t.index ["seen_by_admin"], name: "index_customers_on_seen_by_admin"
  end

  create_table "homepage_sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "headline"
    t.string "identifier", null: false
    t.string "label"
    t.string "link_text"
    t.string "link_url"
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_homepage_sections_on_identifier", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "paid_at"
    t.string "payment_provider"
    t.string "paypal_order_id"
    t.boolean "seen_by_admin", default: false, null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "tax_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.string "tax_region"
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["paypal_order_id"], name: "index_orders_on_paypal_order_id", unique: true
    t.index ["seen_by_admin"], name: "index_orders_on_seen_by_admin"
    t.index ["stripe_checkout_session_id"], name: "index_orders_on_stripe_checkout_session_id", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "brand"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "dimensions"
    t.string "name"
    t.boolean "new_arrival", default: false, null: false
    t.decimal "original_price"
    t.decimal "price"
    t.datetime "updated_at", null: false
    t.index ["new_arrival"], name: "index_products_on_new_arrival"
  end

  create_table "return_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.string "reason"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id"], name: "index_return_items_on_order_item_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "unsubscribe_token", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscribers_on_email", unique: true
    t.index ["unsubscribe_token"], name: "index_subscribers_on_unsubscribe_token", unique: true
  end

  create_table "tax_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "europe_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "international_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "uk_percent", precision: 5, scale: 2, default: "20.0", null: false
    t.datetime "updated_at", null: false
    t.decimal "us_percent", precision: 5, scale: 2, default: "0.0", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "return_items", "order_items"
end
