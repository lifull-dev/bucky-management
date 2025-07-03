class AddEndTimeAndDurationToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :end_time, :datetime
    add_column :jobs, :duration, :float
  end
end
