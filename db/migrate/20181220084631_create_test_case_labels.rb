class CreateTestCaseLabels < ActiveRecord::Migration[5.2]
  def change
    create_table :test_case_labels do |t|
      t.references :test_case, foreign_key: true
      t.references :label, foreign_key: true
    end
  end
end
