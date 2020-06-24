# frozen_string_literal: true

class PagesController < ApplicationController
  def main
    @data_for_top = []
    %w[e2e linkstatus].each do |test_category|
      %w[pc sp].each do |device|
        @latest_job = Job.get_job(test_category, device).last
        @data_for_top.push(TestCaseResult.get_data_for_top_page(@latest_job, test_category, device)) if @latest_job.present?
      end
    end
    gon.data_for_top = @data_for_top
    gon.controller_name = controller_name
    gon.action_name = action_name
  end
end
