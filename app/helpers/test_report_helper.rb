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
    indent_num == 0 ? '' : ('&nbsp;&nbsp;' * indent_num + '└&nbsp;')
  end

  def job_pass_rate(passed_count, failed_count)
    passed_count + failed_count > 0 ? "#{passed_count * 100 / (passed_count + failed_count)}%" : 'no result'
  end

  def job_duration(duration)
    duration ? format('%02d:%02d', duration.to_i / 60, duration.to_i % 60) : '-'
  end

  def search_type_options
    [['Command', 'search_word'], ['Job ID', 'job_id'], ['Device', 'device'], ['PR NUM', 'base_fqdn']]
  end
end
