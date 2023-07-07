# frozen_string_literal: true

module TestReportHelper
  def owner_and_ripository(full_path)
    full_path.sub(%r{(https://github.com/[^/]+/[^/]+)/.*}, '\1')
  end
end
