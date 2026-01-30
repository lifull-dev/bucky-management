class AddEndTimeAndDurationToJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :jobs, :end_time, :datetime, precision: 0
    add_column :jobs, :duration, :float
  end
end
