# frozen_string_literal: true

class TestReportsController < ApplicationController
  def index
    @jobs = Job.join_with_suites
               .select_group_concat_suites
               .group('jobs.id')
               .page(params[:page]).per(30)
               .order('jobs.id DESC')
    @test_case_result = TestCaseResult
  end

  def show
    @latest_round = TestCaseResult.get_latest_round(params[:id])
    # if round exists, use the round number
    @round = if params[:round].nil?
               @latest_round
             else
               raise ActiveRecord::RecordNotFound unless params[:round].match?(/\A[1-9][0-9]*\z/)
               params[:round]
             end
    @job = Job.find(params[:id])
    @suite_data = Job.join_with_suites
                     .select_group_concat_suites
                     .group('jobs.id')
                     .find(params[:id])
    @data_for_test_reports = TestCaseResult.get_data_for_test_reports_page(params[:id], @round)

    gon.passed_count = @data_for_test_reports[:stack_passed_counts]
    gon.failed_count = @data_for_test_reports[:failed_count]
  end
end
