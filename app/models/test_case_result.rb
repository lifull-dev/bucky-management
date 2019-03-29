# frozen_string_literal: true

# == Schema Information
#
# Table name: test_case_results
#
#  id            :bigint(8)        not null, primary key
#  test_case_id  :bigint(8)
#  error_title   :text(65535)
#  error_message :text(65535)
#  elapsed_time  :float(24)        not null
#  is_error      :boolean          not null
#  job_id        :bigint(8)        not null
#  round         :integer          not null
#
# Indexes
#
#  index_test_case_results_on_job_id        (job_id)
#  index_test_case_results_on_test_case_id  (test_case_id)
#
# Foreign Keys
#
#  fk_rails_...  (job_id => jobs.id)
#  fk_rails_...  (test_case_id => test_cases.id)
#

class TestCaseResult < ApplicationRecord
  belongs_to :test_case
  belongs_to :job

  scope :get_total_elapsed_time, ->(job_id, round) { joins(:job).where(job_id: job_id).where(round: round).sum(:elapsed_time) }
  scope :get_total_counts, ->(job_id, round) { where(job_id: job_id).where(round: round).count }
  scope :get_passed_counts, ->(job_id, round) { where(job_id: job_id).where(round: round).where(is_error: 0).count }
  scope :get_failed_counts, ->(job_id, round) { where(job_id: job_id).where(round: round).where(is_error: 1).count }
  scope :get_total_passed_counts, ->(job_id) { where(job_id: job_id).where(is_error: 0).count }
  scope :get_stack_passed_counts, ->(job_id, round) { where(job_id: job_id).where(round: 1..round.to_i).where(is_error: 0).count }
  scope :get_latest_round, ->(job_id) { joins(:job).where(job_id: job_id).last.round }
  scope :get_failed_cases, ->(job_id, round) { joins(test_case: :test_suite).select('test_cases.*, test_case_results.*, test_suites.*').where(job_id: job_id).where(round: round).where(is_error: true) }
  scope :get_slow_time_cases, ->(job_id, round) { joins(test_case: :test_suite).select('test_cases.*, test_case_results.*, test_suites.*').where(job_id: job_id).where(round: round).order('elapsed_time desc').where('elapsed_time >= 60') }
  scope :get_case_successed_counts, ->(test_case_id) { where(test_case_id: test_case_id).where(is_error: 0).order('id desc').limit(20).count }
  scope :get_case_failed_counts, ->(test_case_id) { where(test_case_id: test_case_id).where(is_error: 1).order('id desc').limit(20).count }

  class << self
    def get_latest_result(test_case_id)
      where(test_case_id: test_case_id).last
    end

    def get_latest_failed_result(test_case_id)
      joins(:job).select('jobs.*, test_case_results.is_error').where(test_case_id: test_case_id).where(is_error: true).last
    end

    def get_data_for_top_page(job, test_category, device)
      data_for_top = {}
      data_for_top[:job_id] = job[:id]
      data_for_top[:command_and_option] = job[:command_and_option]
      data_for_top[:start_time] = job[:start_time]
      data_for_top[:title_name] = test_category + '-' + device
      data_for_top[:latest_round] = get_latest_round(job[:id])
      data_for_top[:latest_passed_count] = get_total_passed_counts(job[:id])
      data_for_top[:latest_failed_count] = get_failed_counts(job[:id], data_for_top[:latest_round])
      data_for_top
    end

    def get_data_for_test_reports_page(job_id, round)
      data_for_test_reports = {}
      data_for_test_reports[:total_elapsed_time] = get_total_elapsed_time(job_id, round)
      data_for_test_reports[:passed_count] = get_passed_counts(job_id, round)
      data_for_test_reports[:failed_count] = get_failed_counts(job_id, round)
      data_for_test_reports[:failed_test_cases] = get_failed_cases(job_id, round)
      data_for_test_reports[:slow_time_test_cases] = get_slow_time_cases(job_id, round)
      data_for_test_reports[:stack_passed_counts] = get_stack_passed_counts(job_id, round)
      data_for_test_reports
    end
  end
end
