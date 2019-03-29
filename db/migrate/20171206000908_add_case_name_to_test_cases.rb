# frozen_string_literal: true

class AddCaseNameToTestCases < ActiveRecord::Migration[5.1]
  def change
    add_column :test_cases, :case_name, :string
  end
end
