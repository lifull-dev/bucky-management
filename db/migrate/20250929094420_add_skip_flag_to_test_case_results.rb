class AddSkipFlagToTestCaseResults < ActiveRecord::Migration[7.1]
  def change
    add_column :test_case_results, :skip_flag, :boolean, default: false, null: false
    add_column :test_case_results, :skip_reason, :text
  end
end
