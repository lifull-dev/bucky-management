# frozen_string_literal: true

class TestReportsController < ApplicationController
  before_action :check_round, only: %i[show update]
  PER_PAGE = 30
  def index
    start_num = params[:page].nil? || params[:page] == 1 ? 0 : PER_PAGE * (params[:page].to_i - 1)
    root_jobs, @page = if params[:search_word]
                         Job.get_searched_root_jobs(start_num, PER_PAGE, params[:search_word], params[:page])
                       else
                         Job.root_jobs(start_num, PER_PAGE, params[:page])
                       end
    @jobs = []
    return if root_jobs.empty?

    # Guessed the number of chiled_jobs per page is obtained by PER_PAGE*4
    children_jobs = Job.children_jobs(root_jobs.each(&:id).min.id, PER_PAGE * 4)
    root_job_tree = Job.create_job_tree(root_jobs, children_jobs)
    children_job_tree = Job.create_job_tree(children_jobs, children_jobs)

    root_jobs.each { |job| child_loop(root_job_tree.merge(children_job_tree), job[:id], 0) }

    @test_case_result = TestCaseResult
    gon.controller_name = controller_name
    gon.action_name = action_name
  end

  def show
    respond_to do |format|
      format.html do
        set_var_for_show
      end
      format.js do
        check_update = TestCaseResult.get_failed_cases(params[:id], @round).check_update_in_ten_sec.ids
        if check_update.empty?
          render body: nil
        else
          set_var_for_show
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

    set_var_for_render

    respond_to do |format|
      format.js { render 'show.js.erb' }
    end
  end

  private

  def check_round
    set_job_id
    @latest_round = TestCaseResult.get_latest_round(@job_id)
    # if round exists, use the round number
    @round = if params[:round].nil?
               @latest_round
             else
               raise ActiveRecord::RecordNotFound unless params[:round].match?(/\A[1-9][0-9]*\z/)

               params[:round]
             end
  end

  def set_job_id
    case params[:action]
    when 'show'
      @job_id = params[:id]
    when 'update'
      @job_id = params[:job_id]
    end
  end

  def set_var_for_render
    @select_option = { Unchecked: '', OK: 1, Degradation: 2, 'Fix test script': 3, Checking: 4 }
    @job = Job.find(@job_id)
    @data_for_test_reports = TestCaseResult.get_data_for_test_reports_page(@job_id, @round)
  end

  def set_var_for_show
    @suite_data = Job.join_with_suites
                     .select_group_concat_suites
                     .group('jobs.id')
                     .find(@job_id)
    set_var_for_render
    gon.passed_count = @data_for_test_reports[:stack_passed_counts]
    gon.failed_count = @data_for_test_reports[:failed_count]
    gon.controller_name = controller_name
    gon.action_name = action_name
  end
end
