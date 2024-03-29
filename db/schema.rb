# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_06_203828) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "cube"
  enable_extension "earthdistance"
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "one_time_password_hash"
    t.datetime "one_time_password_validity"
    t.string "phone_number"
    t.string "device_id"
    t.string "name"
    t.string "type"
    t.string "authentication_method"
    t.string "password_digest"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.bigint "user_id"
    t.index ["phone_number"], name: "index_accounts_on_phone_number"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_accounts", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.integer "country_code"
    t.integer "phone_number_digits_min"
    t.integer "phone_number_digits_max"
    t.string "area_code_regex"
    t.index ["abbreviation"], name: "index_countries_on_abbreviation"
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true
  end

  create_table "devices", force: :cascade do |t|
    t.string "password_digest"
    t.datetime "password_validity"
    t.string "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "merchant_id"
    t.index ["merchant_id"], name: "index_devices_on_merchant_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: true
  end

  create_table "logs", force: :cascade do |t|
    t.string "log_type"
    t.string "message"
    t.string "context"
    t.bigint "current_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id"
    t.bigint "group_id"
    t.bigint "user_id"
    t.index ["account_id"], name: "index_memberships_on_account_id"
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "merchant_pass_queues", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.bigint "pass_id", null: false
    t.integer "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_merchant_pass_queues_on_account_id"
    t.index ["merchant_id", "code"], name: "index_merchant_pass_queues_on_merchant_id_and_code"
    t.index ["merchant_id"], name: "index_merchant_pass_queues_on_merchant_id"
    t.index ["pass_id"], name: "index_merchant_pass_queues_on_pass_id"
  end

  create_table "merchant_products", force: :cascade do |t|
    t.bigint "merchant_id"
    t.bigint "product_id"
    t.integer "price_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_merchant_products_on_merchant_id"
    t.index ["product_id"], name: "index_merchant_products_on_product_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.string "phone_number"
    t.string "stripe_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.float "latitude"
    t.float "longitude"
    t.bigint "country_id"
    t.index ["country_id"], name: "index_merchants_on_country_id"
    t.index ["user_id"], name: "index_merchants_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at"
    t.string "status"
    t.string "charge_stripe_id"
    t.integer "charge_amount_cents"
    t.integer "commitment_amount_cents"
    t.bigint "user_id"
    t.index ["account_id"], name: "index_orders_on_account_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "passes", force: :cascade do |t|
    t.string "serial_number"
    t.datetime "expiration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message"
    t.integer "order_id"
    t.integer "buyable_id"
    t.string "buyable_type"
    t.bigint "merchant_id"
    t.string "transfer_stripe_id"
    t.integer "transfer_amount_cents"
    t.datetime "transfer_created_at"
    t.integer "value_cents"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.bigint "redeemed_by_id"
    t.index ["merchant_id"], name: "index_passes_on_merchant_id"
    t.index ["order_id"], name: "index_passes_on_order_id"
    t.index ["recipient_type", "recipient_id"], name: "index_passes_on_recipient_type_and_recipient_id"
    t.index ["redeemed_by_id"], name: "index_passes_on_redeemed_by_id"
  end

  create_table "pending_passes", force: :cascade do |t|
    t.string "message"
    t.integer "order_id"
    t.integer "buyable_id"
    t.string "buyable_type"
    t.integer "value_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.index ["order_id"], name: "index_pending_passes_on_order_id"
    t.index ["recipient_type", "recipient_id"], name: "index_pending_passes_on_recipient_type_and_recipient_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.integer "max_price_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fee_cents"
  end

  create_table "promotions", force: :cascade do |t|
    t.string "name"
    t.string "copy"
    t.string "product"
    t.integer "product_id"
    t.integer "product_qty"
    t.integer "price_cents"
    t.datetime "end_date"
    t.string "image_url"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "picture_url"
    t.string "locale"
    t.string "stripe_customer_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "passes", "accounts", column: "redeemed_by_id"
  add_foreign_key "passes", "merchants"
end
