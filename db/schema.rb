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

ActiveRecord::Schema.define(version: 2019_01_12_195305) do

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
    t.index ["phone_number"], name: "index_accounts_on_phone_number"
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
    t.index ["country_code"], name: "index_countries_on_country_code"
  end

  create_table "logs", force: :cascade do |t|
    t.string "log_type"
    t.string "message"
    t.string "context"
    t.bigint "current_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at"
    t.index ["account_id"], name: "index_orders_on_account_id"
  end

  create_table "passes", force: :cascade do |t|
    t.string "serialNumber"
    t.datetime "expiration"
    t.string "passTypeIdentifier", default: "pass.com.eloisaguanlao.testpass", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.string "message"
    t.integer "order_id"
    t.string "proof_of_purchase"
    t.string "redemption_code"
    t.index ["account_id"], name: "index_passes_on_account_id"
    t.index ["order_id"], name: "index_passes_on_order_id"
  end

end
