# frozen_string_literal: true

class TestSuitesController < ApplicationController
  def index
    @q = TestSuite.ransack(params[:q])
    @test_suites = @q.result.page(params[:page]).per(30)
    gon.controller_name = controller_name
    gon.action_name = action_name
  end

  def show
    @test_cases = TestCase.where(test_suite_id: params[:id])
    @test_suites = TestSuite.find(params[:id])
    @test_case_result = TestCaseResult
    gon.controller_name = controller_name
    gon.action_name = action_name
  end
end
