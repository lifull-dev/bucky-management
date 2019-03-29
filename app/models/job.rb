# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                 :bigint(8)        not null, primary key
#  start_time         :datetime         not null
#  command_and_option :string(255)
#

class Job < ApplicationRecord
  has_many :test_case_results, dependent: :destroy
  has_many :test_cases, through: :test_case_results
  has_many :test_suites, through: :test_cases

  scope :join_with_suites, -> { joins(test_case_results: { test_case: :test_suite }) }
  scope :get_job, ->(test_category, device) { joins(test_case_results: { test_case: :test_suite }).select('jobs.*').where(['test_suites.test_category = ?', test_category]).where(['test_suites.device = ?', device]) }
  scope :select_group_concat_suites, -> { select("jobs.*, GROUP_CONCAT(DISTINCT test_suites.device separator '/') AS device, GROUP_CONCAT(DISTINCT test_suites.service separator '/') AS service, GROUP_CONCAT(DISTINCT test_suites.test_category separator '/') AS category, SUM(test_case_results.elapsed_time) AS total_time") }
end
