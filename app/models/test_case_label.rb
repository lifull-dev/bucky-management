# frozen_string_literal: true

# == Schema Information
#
# Table name: test_case_labels
#
#  id           :bigint(8)        not null, primary key
#  test_case_id :bigint(8)
#  label_id     :bigint(8)
#
# Indexes
#
#  index_test_case_labels_on_label_id      (label_id)
#  index_test_case_labels_on_test_case_id  (test_case_id)
#
# Foreign Keys
#
#  fk_rails_...  (label_id => labels.id)
#  fk_rails_...  (test_case_id => test_cases.id)
#

class TestCaseLabel < ApplicationRecord
  belongs_to :test_case
  belongs_to :label
end
