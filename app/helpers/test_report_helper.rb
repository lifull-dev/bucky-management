# frozen_string_literal: true

module TestReportHelper
  def github_repo_base_url(full_path)
    full_path.sub(%r{(https://github.com/[^/]+/[^/]+)/.*}, '\1')
  end
end
