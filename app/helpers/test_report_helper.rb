# frozen_string_literal: true

module TestReportHelper
  def github_repo_base_url(full_path)
    full_path.sub(%r{(https://github.com/[^/]+/[^/]+)/.*}, '\1')
  end

  def job_stats(job_id)
    latest_round = TestCaseResult.get_latest_round(job_id)
    if latest_round.present?
      fc = TestCaseResult.get_failed_counts(job_id, latest_round)
      pc = TestCaseResult.get_total_passed_counts(job_id)
      tc = TestCaseResult.get_total_counts(job_id, 1)
    else
      fc = 0
      pc = 0
      tc = 0
    end
    { latest_round: latest_round || 0, failed_count: fc, passed_count: pc, total_count: tc }
  end

  def job_indent(indent_num)
    indent_num.zero? ? '' : "#{'&nbsp;&nbsp;' * indent_num}└&nbsp;"
  end

  def job_pass_rate(passed_count, failed_count)
    (passed_count + failed_count).positive? ? "#{passed_count * 100 / (passed_count + failed_count)}%" : 'no result'
  end

  def job_duration(duration)
    duration ? format('%<min>02d:%<sec>02d', min: duration.to_i / 60, sec: duration.to_i % 60) : '-'
  end

  def search_type_options
    [['Command', 'search_word'], ['Job ID', 'job_id'], ['PR NUM', 'base_fqdn']]
  end

  def device_options
    [['All Device', ''], ['SP', 'sp'], ['PC', 'pc']]
  end

  # Extract PR number from base_fqdn (e.g. "https://www-test12826.develop.homes.co.jp" -> "12826")
  def extract_pr_number(base_fqdn)
    return nil if base_fqdn.blank?

    match = base_fqdn.match(/www-test(\d+)\./)
    match ? match[1] : nil
  end

  # Determine repository name from command_and_option
  def detect_repo_name(command_and_option)
    return nil if command_and_option.blank?

    if command_and_option.include?('work-in-homes-pc')
      'homes-pc'
    elsif command_and_option.include?('work-in-homes-sp')
      'homes-sp'
    end
  end

  # Generate GitHub PR link URL
  def github_pr_url(base_fqdn, command_and_option)
    pr_number = extract_pr_number(base_fqdn)
    repo = detect_repo_name(command_and_option)
    org_base_url = ENV['GITHUB_ORG_BASE_URL']
    return nil if pr_number.nil? || repo.nil? || org_base_url.blank?

    "#{org_base_url}/#{repo}/pull/#{pr_number}"
  end

  # Generate issue search URL for a given case name
  def issue_search_url(case_name)
    base = ENV['ISSUE_SEARCH_BASE_URL']
    return nil if base.blank? || case_name.blank?

    "#{base}?q=is%3Aissue%20state%3Aopen%20%20#{ERB::Util.url_encode(case_name)}"
  end
end
