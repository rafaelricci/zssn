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

ActiveRecord::Schema[8.0].define(version: 2025_05_25_035508) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "infection_reports", force: :cascade do |t|
    t.bigint "reporter_id", null: false
    t.bigint "reported_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_id"], name: "index_infection_reports_on_reported_id"
    t.index ["reporter_id"], name: "index_infection_reports_on_reporter_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.integer "kind", null: false
    t.integer "quantity", default: 0, null: false
    t.bigint "survivor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survivor_id"], name: "index_inventories_on_survivor_id"
  end

  create_table "survivors", force: :cascade do |t|
    t.string "name", null: false
    t.integer "age", null: false
    t.integer "gender", null: false
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.boolean "infected", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "infection_reports", "survivors", column: "reported_id"
  add_foreign_key "infection_reports", "survivors", column: "reporter_id"
  add_foreign_key "inventories", "survivors"
end
