# frozen_string_literal: true

class ChangeCaseNameToNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :test_cases, :case_name, false
  end
end
