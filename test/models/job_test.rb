# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                 :bigint(8)        not null, primary key
#  start_time         :datetime         not null
#  command_and_option :string(255)
#

require 'test_helper'

class JobTest < ActiveSupport::TestCase
end
