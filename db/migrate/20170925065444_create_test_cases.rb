# frozen_string_literal: true

class CreateTestCases < ActiveRecord::Migration[5.1]
  def change
    create_table :test_cases do |t|
      t.references :test_suite, foreign_key: true
      t.string :case_description, null: false
    end
  end
end
