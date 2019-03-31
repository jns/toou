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

ActiveRecord::Schema.define(version: 2019_03_31_042304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "one_time_password_hash"
    t.datetime "one_time_password_validity"
    t.string "phone_number"
    t.string "device_id"
    t.string "stripe_customer_id"
    t.string "name"
    t.index ["phone_number"], name: "index_accounts_on_phone_number"
  end

  create_table "admin_accounts", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "charges", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "merchant_id"
    t.integer "source_amount_cents"
    t.integer "destination_amount_cents"
    t.string "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_charges_on_account_id"
    t.index ["merchant_id"], name: "index_charges_on_merchant_id"
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
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.bigint "merchant_id"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_locations_on_merchant_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "log_type"
    t.string "message"
    t.string "context"
    t.bigint "current_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["user_id"], name: "index_merchants_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at"
    t.index ["account_id"], name: "index_orders_on_account_id"
  end

  create_table "passes", force: :cascade do |t|
    t.string "serial_number"
    t.datetime "expiration"
    t.string "passTypeIdentifier", default: "pass.com.eloisaguanlao.testpass", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.string "message"
    t.integer "order_id"
    t.string "redemption_code"
    t.integer "buyable_id"
    t.string "buyable_type"
    t.bigint "charge_id"
    t.index ["account_id"], name: "index_passes_on_account_id"
    t.index ["charge_id"], name: "index_passes_on_charge_id"
    t.index ["order_id"], name: "index_passes_on_order_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.integer "max_price_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
