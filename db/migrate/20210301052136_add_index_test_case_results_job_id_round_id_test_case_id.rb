class AddIndexTestCaseResultsJobIdRoundIdTestCaseId < ActiveRecord::Migration[5.2]
  def change
    add_index :test_case_results, [:job_id, :round, :test_case_id]
  end
end
