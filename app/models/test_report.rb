# frozen_string_literal: true

class TestReport < ApplicationRecord
  def self.create_child_parent_pair(job)
    return nil if job.command_and_option.nil?

    match = job.command_and_option.match(/--job_id (\d+)|-j (\d+)|--job-id (\d+)/)
    return nil if match.nil?

    match[1].to_i
  end
end
