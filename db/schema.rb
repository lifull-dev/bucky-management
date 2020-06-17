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

ActiveRecord::Schema.define(version: 2020_06_17_023427) do

  create_table "jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.string "command_and_option"
  end

  create_table "labels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "label_name", null: false
  end

  create_table "test_case_labels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "test_case_id"
    t.bigint "label_id"
    t.index ["label_id"], name: "index_test_case_labels_on_label_id"
    t.index ["test_case_id"], name: "index_test_case_labels_on_test_case_id"
  end

  create_table "test_case_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "test_case_id"
    t.text "error_title"
    t.text "error_message"
    t.float "elapsed_time", null: false
    t.boolean "is_error", null: false
    t.bigint "job_id", null: false
    t.integer "round", null: false
    t.integer "check_status"
    t.text "check_comment"
    t.datetime "updated_at"
    t.index ["job_id"], name: "index_test_case_results_on_job_id"
    t.index ["test_case_id"], name: "index_test_case_results_on_test_case_id"
  end

  create_table "test_cases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "test_suite_id"
    t.string "case_description", null: false
    t.string "case_name", null: false
    t.index ["test_suite_id"], name: "index_test_cases_on_test_suite_id"
  end

  create_table "test_suites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
