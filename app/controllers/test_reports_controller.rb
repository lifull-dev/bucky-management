# frozen_string_literal: true

class TestReportsController < ApplicationController
  before_action :check_round, only: %i[show update]
  def index
    per_page = 30
    start_num = params[:page].nil? || params[:page] == 1 ? 0 : per_page * (params[:page].to_i - 1)
    logger.debug("〜〜〜〜〜#{params[:page]}")

    root_jobs, @page = if params[:search_word]
      logger.debug("tureです")
                  Job.root_jobs_by_search_word(start_num, per_page, params[:search_word], params[:page])
                else
                  logger.debug("faleです")
                  Job.root_jobs(start_num, per_page, params[:page])
                end
    logger.debug("@page#{@page.count}") #@page

    @jobs = []
    return if root_jobs.empty?

    # Guessed the number of chiled_jobs per page is obtained by per_page*4
    children_jobs = Job.children_jobs(root_jobs.each(&:id).min.id, per_page * 4)
    root_job_tree = Job.create_job_tree(root_jobs, children_jobs)
    children_job_tree = Job.create_job_tree(children_jobs, children_jobs)

    root_jobs.each { |job| child_loop(root_job_tree.merge(children_job_tree), job[:id], 0) }

    @test_case_result = TestCaseResult
    gon.controller_name = controller_name
    gon.action_name = action_name
  end

  def show
    respond_to do |format|
      format.html { set_var_for_show }
      format.js do
        check_update = TestCaseResult.get_failed_cases(params[:id], @round).check_update_in_ten_sec.ids
        if check_update.empty?
          render body: nil
        else
          set_var_for_show
          render 'check_status'
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
      format.js { render 'check_status' }
    end
  end

  private

  def child_loop(job_tree, job_id, indent_num)
    @jobs << job_tree[job_id]
    @jobs.last[:indent_num] = indent_num
    indent_num += 1
    job_tree[job_id][:children].reverse_each { |child_job_id| child_loop(job_tree, child_job_id, indent_num) }
  end

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
    @suite_data = Job.join_with_suites([@job_id]).first
    set_var_for_render
    gon.passed_count = @data_for_test_reports[:stack_passed_counts]
    gon.failed_count = @data_for_test_reports[:failed_count]
    gon.controller_name = controller_name
    gon.action_name = action_name
  end
end
