# frozen_string_literal: true

class TestReportsController < ApplicationController
  before_action :check_round, only: %i[show update]

  def index
    per_page = 30
    @jobs = Job.all
               .page(params[:page])
               .per(per_page)
               .order('jobs.id DESC')
    job_ids = Job.select('id').page(params[:page]).per(per_page).order('jobs.id DESC').to_a
    @joined_jobs = Job.join_with_suites
                      .select_group_concat_suites
                      .group('jobs.id')
                      .where(id: job_ids)
                      .order('jobs.id DESC')

    @job_trees = create_job_trees(@joined_jobs)

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

  def create_job_trees(jobs)
    child_parent_pair = {}

    jobs.each { |job| child_parent_pair[job.id] = TestReport.create_child_parent_pair(job) }
    parent_jobs = child_parent_pair.select { |_k, v| v.nil? }.keys

    job_trees = {}
    parent_jobs.each do |parent_id|
      job_trees[parent_id] = {}
      job_trees[parent_id][:parent] = jobs.select { |job| job.id == parent_id }.first

      job_trees[parent_id][:children] = []
      child_parent_pair.each do |child, parent|
        job_trees[parent_id][:children] << jobs.select { |job| job.id == child }.first if parent_id == parent
      end
    end

    job_trees
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
