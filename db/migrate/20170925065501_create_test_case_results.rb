# frozen_string_literal: true

class CreateTestCaseResults < ActiveRecord::Migration[5.1]
  def change
    create_table :test_case_results do |t|
      t.references :test_case, foreign_key: true
      t.text :error_title
      t.text :error_message
      t.float :elapsed_time, null: false
      t.boolean :is_error, null: false
      t.references :job, foreign_key: true, null: false
      t.integer :round, null: false
    end
  end
end
