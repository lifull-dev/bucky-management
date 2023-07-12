# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestReportHelper, type: :helper do
  describe '正常系のテスト' do
    it 'ripository以降のリンクが削除されていること' do
      url = 'https://github.com/hoge/fuga/blob/master'
      assert_equal 'https://github.com/hoge/fuga', github_repo_base_url(url)
    end
  end
end
