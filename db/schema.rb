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

ActiveRecord::Schema[7.1].define(version: 2024_05_30_103925) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agreement_framework_lots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agreement_id", null: false
    t.uuid "framework_lot_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["agreement_id"], name: "index_agreement_framework_lots_on_agreement_id"
    t.index ["framework_lot_id"], name: "index_agreement_framework_lots_on_framework_lot_id"
  end

  create_table "agreements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.uuid "supplier_id", null: false
    t.boolean "active", default: true
    t.index ["active"], name: "index_agreements_on_active"
    t.index ["framework_id"], name: "index_agreements_on_framework_id"
    t.index ["supplier_id"], name: "index_agreements_on_supplier_id"
  end

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_api_keys_on_key", unique: true
  end

  create_table "bulk_user_uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "aasm_state"
    t.index ["aasm_state"], name: "index_bulk_user_uploads_on_aasm_state"
  end

  create_table "customer_effort_scores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "rating", null: false
    t.string "comments"
    t.datetime "created_at", precision: nil
    t.uuid "user_id"
    t.index ["user_id"], name: "index_customer_effort_scores_on_user_id"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "postcode"
    t.integer "urn", null: false
    t.integer "sector", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "deleted", default: false
    t.boolean "published", default: true
    t.index ["name"], name: "index_customers_on_name"
    t.index ["postcode"], name: "index_customers_on_postcode"
    t.index ["sector"], name: "index_customers_on_sector"
    t.index ["urn"], name: "index_customers_on_urn", unique: true
  end

  create_table "data_warehouse_exports", force: :cascade do |t|
    t.datetime "range_from", precision: nil, null: false
    t.datetime "range_to", precision: nil, null: false
    t.index ["range_to"], name: "index_data_warehouse_exports_on_range_to"
  end

  create_table "event_store_events", id: :serial, force: :cascade do |t|
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.text "metadata"
    t.text "data", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "valid_at"
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
    t.index ["valid_at"], name: "index_event_store_events_on_valid_at"
  end

  create_table "event_store_events_in_streams", id: :serial, force: :cascade do |t|
    t.string "stream", null: false
    t.integer "position"
    t.uuid "event_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "framework_lots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.string "number", null: false
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["framework_id", "number"], name: "index_framework_lots_on_framework_id_and_number", unique: true
    t.index ["framework_id"], name: "index_framework_lots_on_framework_id"
  end

  create_table "frameworks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "short_name", null: false
    t.text "definition_source", null: false
    t.boolean "published", default: false
    t.index ["short_name"], name: "index_frameworks_on_short_name", unique: true
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "supplier_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["supplier_id"], name: "index_memberships_on_supplier_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "notification_message"
    t.boolean "published", default: false
    t.datetime "published_at"
    t.datetime "unpublished_at"
    t.string "user"
    t.index ["published"], name: "index_notifications_on_published"
  end

  create_table "submission_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.uuid "submission_file_id"
    t.jsonb "source"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "aasm_state"
    t.jsonb "validation_errors"
    t.string "entry_type"
    t.decimal "total_value"
    t.decimal "management_charge", precision: 18, scale: 4
    t.integer "customer_urn"
    t.index ["aasm_state"], name: "index_submission_entries_on_aasm_state"
    t.index ["entry_type"], name: "index_submission_entries_on_entry_type"
    t.index ["entry_type"], name: "index_submission_entries_on_invoice_entry_type", where: "((entry_type)::text = 'invoice'::text)"
    t.index ["source"], name: "index_submission_entries_on_source", using: :gin
    t.index ["submission_file_id"], name: "index_submission_entries_on_submission_file_id"
    t.index ["submission_id"], name: "index_submission_entries_on_submission_id"
    t.index ["updated_at"], name: "index_submission_entries_on_updated_at", using: :brin
  end

  create_table "submission_entries_stages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.uuid "submission_file_id"
    t.jsonb "source"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "aasm_state"
    t.jsonb "validation_errors"
    t.string "entry_type"
    t.decimal "total_value"
    t.decimal "management_charge", precision: 18, scale: 4
    t.integer "customer_urn"
    t.index ["aasm_state"], name: "index_submission_entries_stages_on_aasm_state"
    t.index ["entry_type"], name: "index_submission_entries_stage_on_invoice_entry_type", where: "((entry_type)::text = 'invoice'::text)"
    t.index ["entry_type"], name: "index_submission_entries_stages_on_entry_type"
    t.index ["source"], name: "index_submission_entries_stages_on_source", using: :gin
    t.index ["submission_file_id"], name: "index_submission_entries_stages_on_submission_file_id"
    t.index ["submission_id"], name: "index_submission_entries_stages_on_submission_id"
    t.index ["updated_at"], name: "index_submission_entries_stages_on_updated_at", using: :brin
  end

  create_table "submission_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.integer "rows"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["submission_id"], name: "index_submission_files_on_submission_id"
  end

  create_table "submission_invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.string "workday_reference"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "reversal", default: false, null: false
    t.index ["submission_id"], name: "index_submission_invoices_on_submission_id"
  end

  create_table "submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.uuid "supplier_id", null: false
    t.string "aasm_state"
    t.uuid "task_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "purchase_order_number"
    t.uuid "created_by_id"
    t.uuid "submitted_by_id"
    t.datetime "submitted_at", precision: nil
    t.decimal "management_charge_total", precision: 18, scale: 4
    t.decimal "invoice_total", precision: 18, scale: 4
    t.index ["aasm_state"], name: "index_submissions_on_aasm_state"
    t.index ["created_at"], name: "index_submissions_on_created_at", order: :desc
    t.index ["created_by_id"], name: "index_submissions_on_created_by_id"
    t.index ["framework_id"], name: "index_submissions_on_framework_id"
    t.index ["submitted_by_id"], name: "index_submissions_on_submitted_by_id"
    t.index ["supplier_id"], name: "index_submissions_on_supplier_id"
    t.index ["task_id"], name: "index_submissions_on_task_id"
    t.index ["updated_at"], name: "index_submissions_on_updated_at", using: :brin
  end

  create_table "suppliers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "salesforce_id"
    t.index ["salesforce_id"], name: "index_suppliers_on_salesforce_id", unique: true
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "description"
    t.date "due_on"
    t.integer "period_month"
    t.integer "period_year"
    t.uuid "supplier_id"
    t.uuid "framework_id"
    t.index ["framework_id"], name: "index_tasks_on_framework_id"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["supplier_id"], name: "index_tasks_on_supplier_id"
    t.index ["updated_at"], name: "index_tasks_on_updated_at", using: :brin
  end

  create_table "urn_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "aasm_state"
    t.index ["aasm_state"], name: "index_urn_lists_on_aasm_state"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "auth_id"
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["auth_id"], name: "index_users_on_auth_id", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agreement_framework_lots", "agreements"
  add_foreign_key "agreement_framework_lots", "framework_lots"
  add_foreign_key "customer_effort_scores", "users"
  add_foreign_key "framework_lots", "frameworks"
  add_foreign_key "memberships", "suppliers"
  add_foreign_key "submission_entries", "customers", column: "customer_urn", primary_key: "urn"
  add_foreign_key "submission_entries", "submission_files"
  add_foreign_key "submission_entries", "submissions"
  add_foreign_key "submission_entries_stages", "customers", column: "customer_urn", primary_key: "urn"
  add_foreign_key "submission_entries_stages", "submission_files"
  add_foreign_key "submission_entries_stages", "submissions"
  add_foreign_key "submission_files", "submissions"
  add_foreign_key "submission_invoices", "submissions"
  add_foreign_key "submissions", "frameworks"
  add_foreign_key "submissions", "suppliers"
  add_foreign_key "submissions", "tasks"
  add_foreign_key "submissions", "users", column: "created_by_id"
  add_foreign_key "submissions", "users", column: "submitted_by_id"
  add_foreign_key "tasks", "frameworks"
  add_foreign_key "tasks", "suppliers"
end
