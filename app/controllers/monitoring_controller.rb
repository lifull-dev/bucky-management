# frozen_string_literal: true

class MonitoringController < ApplicationController
  DEFAULT_DAYS = 3
  PER_PAGE = 10

  def index
    redirect_to monitoring_job_data_path
  end

  def job_data
    set_date_range
    @job_data = MonitoringQuery.fetch_job_data(@start_date, @end_date)
    @job_summary = MonitoringQuery.calculate_job_summary(@job_data)
    @pages = paginate_by_device(@job_data)
  end

  def case_data
    set_date_range
    @search_value = params[:search_value]
    @case_data = MonitoringQuery.fetch_case_data(@start_date, @end_date)
    @case_data = filter_by_search(@case_data, @search_value)
    @pages = paginate_by_device(@case_data)
  end

  helper_method :permitted_params

  private

  def permitted_params
    params.permit(:date_from, :date_to, :search_value).merge(page_params)
  end

  def page_params
    @pages&.keys&.each_with_object({}) do |device, hash|
      key = "page_#{device}"
      hash[key] = params[key] if params[key].present?
    end || {}
  end

  def set_date_range
    @end_date = parse_date(params[:date_to], Time.zone.today)
    @start_date = parse_date(params[:date_from], @end_date - (DEFAULT_DAYS - 1).days)
  end

  def parse_date(param, default)
    param.present? ? Date.parse(param) : default
  end

  def filter_by_search(data, search_value)
    return data if search_value.blank?

    data.select { |row| row['case_name'].include?(search_value) }
  end

  def paginate_by_device(data)
    data.group_by { |row| row['repo_device'] }.transform_values do |rows|
      device = rows.first['repo_device']
      page = (params["page_#{device}"] || 1).to_i
      Kaminari.paginate_array(rows).page(page).per(PER_PAGE)
    end
  end
end
