# frozen_string_literal: true

class TestReport < ApplicationRecord
  def self.get_parent(command_and_option)
    return nil if command_and_option.nil?

    match = command_and_option.match(/(--job-id|--job_id|-j) (\d+)/)
    return nil if match.nil?

    match[2].to_i
  end
end
