# frozen_string_literal: true

# == Schema Information
#
# Table name: test_cases
#
#  id               :bigint(8)        not null, primary key
#  test_suite_id    :bigint(8)
#  case_description :string(255)      not null
#  case_name        :string(255)      not null
#
# Indexes
#
#  index_test_cases_on_test_suite_id  (test_suite_id)
#
# Foreign Keys
#
#  fk_rails_...  (test_suite_id => test_suites.id)
#

class TestCase < ApplicationRecord
  belongs_to :test_suite
  has_many :test_case_results, dependent: :nullify
  has_many :test_case_labels, dependent: :destroy

  def self.ransackable_associations(_auth_object = nil)
    ['test_case_labels']
  end

  def self.ransackable_attributes(_auth_object = nil)
    ['case_name']
  end
end
