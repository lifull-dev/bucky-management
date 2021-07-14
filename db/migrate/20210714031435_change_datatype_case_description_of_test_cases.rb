class ChangeDatatypeCaseDescriptionOfTestCases < ActiveRecord::Migration[6.1]
  def change
    change_column :test_cases, :case_description, :text
  end
end
