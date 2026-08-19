# frozen_string_literal: true

class GithubUrlBuilder
  def self.extract_pr_number(base_fqdn)
    return nil if base_fqdn.blank?

    match = base_fqdn.match(/[a-z-]*(\d+)\./)
    match ? match[1] : nil
  end

  def self.detect_repo_name(command_and_option)
    return nil if command_and_option.blank?

    mapping_json = ENV.fetch('REPO_MAPPING', nil)
    return nil if mapping_json.blank?

    mapping = JSON.parse(mapping_json)
    return nil unless mapping.is_a?(Hash)

    mapping.find { |keyword, _| command_and_option.include?(keyword) }&.last
  rescue JSON::ParserError
    nil
  end

  def self.pr_url(base_fqdn, command_and_option)
    pr_number = extract_pr_number(base_fqdn)
    repo = detect_repo_name(command_and_option)
    org_base_url = ENV.fetch('GITHUB_ORG_BASE_URL', nil)
    return nil if pr_number.nil? || repo.nil? || org_base_url.blank?

    "#{org_base_url}/#{repo}/pull/#{pr_number}"
  end

  def self.issue_search_url(case_name)
    base = ENV.fetch('ISSUE_SEARCH_BASE_URL', nil)
    return nil if base.blank? || case_name.blank?

    "#{base}?q=is%3Aissue%20state%3Aopen%20#{ERB::Util.url_encode(case_name)}"
  end
end
