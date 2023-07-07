# frozen_string_literal: true

require 'rails_helper'
# require 'app/helpers/test_report_helper.rb'

RSpec.describe TestReportHelper, type: :helper do
  describe '正常系のテスト' do
    it 'ripository以降のリンクが削除されていること' do
      url = 'https://github.com/hoge/fuga/blob/master'
      assert_equal 'https://github.com/hoge/fuga', owner_and_ripository(url)
    end
  end
end
