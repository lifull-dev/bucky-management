class AddCheckStatusAndCommentAndUpdatetime < ActiveRecord::Migration[5.2]
  def change
    add_column :test_case_results, :check_status, :integer
    add_column :test_case_results, :check_comment, :text
    add_column :test_case_results, :updated_at, :datetime
  end
end
