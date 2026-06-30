# frozen_string_literal: true

class TestReportsController < ApplicationController
  before_action :check_round, only: %i[show update]
  PER_PAGE = 30
  def index
    start_num = params[:page].nil? || params[:page] == 1 ? 0 : PER_PAGE * (params[:page].to_i - 1)
    filters = {}
    if params[:search_value].present? && params[:search_type].present?
      filters[params[:search_type].to_sym] = params[:search_value]
    end
    filters[:date_from] = params[:date_from] if params[:date_from].present?
    filters[:date_to] = params[:date_to] if params[:date_to].present?

    result = Job.paginated_root_jobs(start_num, PER_PAGE, filters: filters)
    @page = Kaminari.paginate_array(Array.new(result[:total_count]), total_count: result[:total_count]).page(params[:page]).per(PER_PAGE)
    @jobs = Job.build_job_list(result[:jobs], PER_PAGE)

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
