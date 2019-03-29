# frozen_string_literal: true

# == Schema Information
#
# Table name: labels
#
#  id         :bigint(8)        not null, primary key
#  label_name :string(255)      not null
#

class Label < ApplicationRecord
  has_many :test_case_label, dependent: :destroy
end
