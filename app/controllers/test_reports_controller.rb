# frozen_string_literal: true

class TestReportsController < ApplicationController
  before_action :detail_page_load, only: %i[show update]

  def index
    @jobs = Job.join_with_suites
               .select_group_concat_suites
               .group('jobs.id')
               .page(params[:page]).per(30)
               .order('jobs.id DESC')
    @test_case_result = TestCaseResult
    gon.controller_name = controller_name
    gon.action_name = action_name
  end

  def show
    @suite_data = Job.join_with_suites
                     .select_group_concat_suites
                     .group('jobs.id')
                     .find(params[:id])

    gon.passed_count = @data_for_test_reports[:stack_passed_counts]
    gon.failed_count = @data_for_test_reports[:failed_count]
    gon.controller_name = controller_name
    gon.action_name = action_name

    respond_to do |format|
      format.html
      format.js do
        check_update = TestCaseResult.get_failed_cases(params[:id], @round).check_update_in_ten_sec.ids
        if check_update.empty?
          render body: nil
        else
          render 'show.js.erb'
        end
      end
    end
  end

  def update
    @get_update_target_result = TestCaseResult.find_by(id: params[:result_id])
    if params[:check_comment].strip.empty?
      @get_update_target_result.update(check_status: params[:check_status], check_comment: params[:check_comment].strip)
    else
      @get_update_target_result.update(check_status: params[:check_status], check_comment: params[:check_comment])
    end

    respond_to do |format|
      format.js { render 'show.js.erb' }
    end
  end

  private

  def detail_page_load
    if params[:action] == 'show'
      id = params[:id]
    elsif params[:action] == 'update'
      id = params[:job_id]
    end
    @select_option = { 'Unchecked': '', 'OK': 1, 'Degradation': 2, 'Fix test script': 3, 'Checking': 4 }
    @job = Job.find(id)
    @latest_round = TestCaseResult.get_latest_round(id)
    # if round exists, use the round number
    @round = if params[:round].nil?
               @latest_round
             else
               raise ActiveRecord::RecordNotFound unless params[:round].match?(/\A[1-9][0-9]*\z/)
               params[:round]
             end
    @data_for_test_reports = TestCaseResult.get_data_for_test_reports_page(id, @round)
  end
end
