# frozen_string_literal: true

# == Schema Information
#
# Table name: test_suites
#
#  id                :bigint(8)        not null, primary key
#  test_category     :string(255)      not null
#  service           :string(255)      not null
#  device            :string(255)      not null
#  priority          :string(255)      not null
#  test_suite_name   :string(255)      not null
#  suite_description :string(255)      not null
#  github_url        :string(255)      not null
#  file_path         :string(255)      not null
#

class TestSuite < ApplicationRecord
  has_many :test_cases, dependent: :destroy

  def self.ransackable_attributes(_auth_object = nil)
    ['id']
  end
end
