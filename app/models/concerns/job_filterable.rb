# frozen_string_literal: true

module JobFilterable
  extend ActiveSupport::Concern

  ALLOWED_SEARCH_TYPES = %w[search_word job_id base_fqdn].freeze

  class_methods do
    def build_index_filters(params, initial_request: false)
      filters = {}
      filters.merge!(build_search_filter(params))
      filters[:device] = params[:device] if params[:device].present?
      filters.merge!(build_date_filters(params, initial_request))
      filters
    end

    def build_search_filter(params)
      return {} unless params[:search_value].present? && params[:search_type].present?
      return {} unless ALLOWED_SEARCH_TYPES.include?(params[:search_type])

      { params[:search_type].to_sym => params[:search_value] }
    end

    def build_date_filters(params, initial_request)
      if initial_request
        { date_from: 1.week.ago.to_date.to_s, date_to: Time.zone.today.to_s }
      else
        {}.tap do |f|
          f[:date_from] = params[:date_from] if params[:date_from].present?
          f[:date_to] = params[:date_to] if params[:date_to].present?
        end
      end
    end
  end
end
