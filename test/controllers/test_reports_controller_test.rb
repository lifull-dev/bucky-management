# frozen_string_literal: true

require 'test_helper'
require_relative '../../app/controllers/test_reports_controller'

class TestReportsControllerTest < ActionDispatch::IntegrationTest
  test '@have_command_and_option_joined_jobsがcommand&option : idを返すこと' do
    get '/test_reports/'
    assert_includes(assigns(:have_command_and_option_joined_jobs), ['bucky rerun --job-id 53', 55])
  end

  test '@child_parent_pairに 子job自身のid => 親jobのidが格納されているか' do
    get '/test_reports/'
    assert_equal(assigns(:child_parent_pair)[55], 53)
  end
end
