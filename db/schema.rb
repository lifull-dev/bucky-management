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

ActiveRecord::Schema[7.1].define(version: 2025_07_03_070828) do
  create_table "jobs", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "start_time", precision: nil, null: false
    t.string "command_and_option"
    t.string "base_fqdn"
    t.datetime "end_time"
    t.float "duration"
  end

  create_table "labels", charset: "utf8mb4", force: :cascade do |t|
    t.string "label_name", null: false
  end

  create_table "test_case_labels", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "test_case_id"
    t.bigint "label_id"
    t.index ["label_id"], name: "index_test_case_labels_on_label_id"
    t.index ["test_case_id"], name: "index_test_case_labels_on_test_case_id"
  end

  create_table "test_case_results", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "test_case_id"
    t.text "error_title"
    t.text "error_message"
    t.float "elapsed_time", null: false
    t.boolean "is_error", null: false
    t.bigint "job_id", null: false
    t.integer "round", null: false
    t.integer "check_status"
    t.text "check_comment"
    t.datetime "updated_at", precision: nil
    t.index ["job_id", "round", "test_case_id"], name: "index_test_case_results_on_job_id_and_round_and_test_case_id"
    t.index ["job_id"], name: "index_test_case_results_on_job_id"
    t.index ["test_case_id"], name: "index_test_case_results_on_test_case_id"
  end

  create_table "test_cases", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "test_suite_id"
    t.text "case_description", null: false
    t.string "case_name", null: false
    t.index ["test_suite_id"], name: "index_test_cases_on_test_suite_id"
  end

  create_table "test_suites", charset: "utf8mb4", force: :cascade do |t|
    t.string "test_category", null: false
    t.string "service", null: false
    t.string "device", null: false
    t.string "priority", null: false
    t.string "test_suite_name", null: false
    t.string "suite_description", null: false
    t.string "github_url", null: false
    t.string "file_path", null: false
  end

  add_foreign_key "test_case_labels", "labels"
  add_foreign_key "test_case_labels", "test_cases"
  add_foreign_key "test_case_results", "jobs"
  add_foreign_key "test_case_results", "test_cases"
  add_foreign_key "test_cases", "test_suites"
end
