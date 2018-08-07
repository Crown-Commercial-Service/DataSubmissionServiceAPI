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

ActiveRecord::Schema.define(version: 2018_08_07_093650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "agreements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.uuid "supplier_id", null: false
    t.index ["framework_id"], name: "index_agreements_on_framework_id"
    t.index ["supplier_id"], name: "index_agreements_on_supplier_id"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "postcode"
    t.integer "urn", null: false
    t.integer "sector", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["postcode"], name: "index_customers_on_postcode"
    t.index ["sector"], name: "index_customers_on_sector"
    t.index ["urn"], name: "index_customers_on_urn", unique: true
  end

  create_table "event_store_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event_type", null: false
    t.text "metadata"
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
  end

  create_table "event_store_events_in_streams", id: :serial, force: :cascade do |t|
    t.string "stream", null: false
    t.integer "position"
    t.uuid "event_id", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "framework_lots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.string "number", null: false
    t.string "description"
    t.index ["framework_id", "number"], name: "index_framework_lots_on_framework_id_and_number", unique: true
    t.index ["framework_id"], name: "index_framework_lots_on_framework_id"
  end

  create_table "frameworks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "short_name", null: false
    t.integer "coda_reference"
    t.index ["short_name"], name: "index_frameworks_on_short_name", unique: true
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_memberships_on_supplier_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "submission_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.uuid "submission_file_id"
    t.jsonb "source"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.jsonb "validation_errors"
    t.index ["aasm_state"], name: "index_submission_entries_on_aasm_state"
    t.index ["submission_file_id"], name: "index_submission_entries_on_submission_file_id"
    t.index ["submission_id"], name: "index_submission_entries_on_submission_id"
  end

  create_table "submission_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.integer "rows"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_submission_files_on_submission_id"
  end

  create_table "submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.uuid "supplier_id", null: false
    t.integer "levy"
    t.string "aasm_state"
    t.uuid "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aasm_state"], name: "index_submissions_on_aasm_state"
    t.index ["framework_id"], name: "index_submissions_on_framework_id"
    t.index ["supplier_id"], name: "index_submissions_on_supplier_id"
    t.index ["task_id"], name: "index_submissions_on_task_id"
  end

  create_table "suppliers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "coda_reference", limit: 7
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.date "due_on"
    t.integer "period_month"
    t.integer "period_year"
    t.uuid "supplier_id"
    t.uuid "framework_id"
    t.index ["framework_id"], name: "index_tasks_on_framework_id"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["supplier_id"], name: "index_tasks_on_supplier_id"
  end

  add_foreign_key "framework_lots", "frameworks"
  add_foreign_key "memberships", "suppliers"
  add_foreign_key "submission_entries", "submission_files"
  add_foreign_key "submission_entries", "submissions"
  add_foreign_key "submission_files", "submissions"
  add_foreign_key "submissions", "frameworks"
  add_foreign_key "submissions", "suppliers"
  add_foreign_key "submissions", "tasks"
  add_foreign_key "tasks", "frameworks"
  add_foreign_key "tasks", "suppliers"
end
