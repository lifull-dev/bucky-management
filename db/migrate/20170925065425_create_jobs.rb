# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.datetime :start_time, null: false
    end
  end
end
