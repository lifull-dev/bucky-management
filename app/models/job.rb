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
  scope :get_job, ->(test_category, device) {
    query = <<-SQL
      SELECT jobs.* FROM jobs
      STRAIGHT_JOIN `test_case_results` ON `test_case_results`.`job_id` = `jobs`.`id`
      INNER JOIN `test_cases` ON `test_cases`.`id` = `test_case_results`.`test_case_id`
      INNER JOIN `test_suites` ON `test_suites`.`id` = `test_cases`.`test_suite_id`
      WHERE `test_suites`.`test_category` = ? AND `test_suites`.`device` = ?
      ORDER BY `jobs`.`id` DESC
      LIMIT 1
    SQL
    find_by_sql([query, test_category, device])
  }
  scope :select_group_concat_suites, -> { select("jobs.*, GROUP_CONCAT(DISTINCT test_suites.device separator '/') AS device, GROUP_CONCAT(DISTINCT test_suites.service separator '/') AS service, GROUP_CONCAT(DISTINCT test_suites.test_category separator '/') AS category, SUM(test_case_results.elapsed_time) AS total_time") }
end
