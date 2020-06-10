class AddCheckStatusAndComment < ActiveRecord::Migration[5.2]
  def change
    add_column :test_case_results, :check_status, :integer
    add_column :test_case_results, :check_comment, :text
  end
end
