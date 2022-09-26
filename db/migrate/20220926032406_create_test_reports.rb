class CreateTestReports < ActiveRecord::Migration[7.0]
  def change
    create_table :test_reports do |t|

      t.timestamps
    end
  end
end
