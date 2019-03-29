# frozen_string_literal: true

class CreateTestSuites < ActiveRecord::Migration[5.1]
  def change
    create_table :test_suites do |t|
      t.string :test_category, null: false
      t.string :service, null: false
      t.string :device, null: false
      t.string :priority, null: false
      t.string :test_suite_name, null: false
      t.string :suite_description, null: false
      t.string :github_url, null: false
      t.string :file_path, null: false
    end
  end
end
