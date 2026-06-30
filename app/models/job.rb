# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                 :bigint(8)        not null, primary key
#  start_time         :datetime         not null
#  command_and_option :string(255)
#

class Job < ApplicationRecord
  has_many :test_case_results, dependent: :destroy
  has_many :test_cases, through: :test_case_results
  has_many :test_suites, through: :test_cases

  scope :join_with_suites, lambda { |job_ids|
                             joins(test_case_results: { test_case: :test_suite }).select_group_concat_suites.group('jobs.id').where(id: job_ids).order('jobs.id DESC')
                           }

  scope :get_job, lambda { |test_category, device|
    query = <<-SQL.squish
      SELECT jobs.* FROM jobs
      STRAIGHT_JOIN `test_case_results` ON `test_case_results`.`job_id` = `jobs`.`id`
      INNER JOIN `test_cases` ON `test_cases`.`id` = `test_case_results`.`test_case_id`
      INNER JOIN `test_suites` ON `test_suites`.`id` = `test_cases`.`test_suite_id`
      WHERE `test_suites`.`test_category` = ? AND `test_suites`.`device` = ?
      ORDER BY `jobs`.`id` DESC
      LIMIT 1
    SQL
    find_by_sql([query, test_category, device])
  }
  scope :select_group_concat_suites, -> { select("jobs.*, GROUP_CONCAT(DISTINCT test_suites.device separator '/') AS device, GROUP_CONCAT(DISTINCT test_suites.service separator '/') AS service, GROUP_CONCAT(DISTINCT test_suites.test_category separator '/') AS category, SUM(test_case_results.elapsed_time) AS total_time") }
  def self.all_root_jobs
    Job.all.where("command_and_option not like '%rerun%'").order('jobs.id DESC')
  end

  def self.paginated_root_jobs(start_num, per_page, filters: {})
    if filters.any?
      all_job_ids = filtered_root_job_ids(filters)
      total_count = all_job_ids.size
      jobs = join_with_suites(all_job_ids[start_num...start_num + per_page])
    else
      total_count = all_root_jobs.count
      jobs = root_jobs(start_num, per_page)
    end
    { jobs: jobs, total_count: total_count }
  end

  def self.searched_root_jobs(search_word)
    all_root_jobs.where('command_and_option LIKE ?', "%#{search_word}%")
  end

  def self.root_jobs(start_num, per_page)
    Job.join_with_suites(Job.all_root_jobs.to_a
        .map(&:id)[start_num...start_num + per_page])
  end

  def self.filtered_root_job_ids(filters)
    jobs = apply_filters(all_root_jobs, filters)
    filter_by_device(jobs, filters[:device])
  end

  def self.apply_filters(jobs, filters)
    jobs = jobs.searched_root_jobs(filters[:search_word]) if filters[:search_word].present?
    jobs = jobs.where(id: filters[:job_id]) if filters[:job_id].present?
    jobs = jobs.where('base_fqdn LIKE ?', "%#{filters[:base_fqdn]}%") if filters[:base_fqdn].present?
    jobs = jobs.where(start_time: filters[:date_from].to_date.beginning_of_day..) if filters[:date_from].present?
    jobs = jobs.where(start_time: ..filters[:date_to].to_date.end_of_day) if filters[:date_to].present?
    jobs
  end

  def self.filter_by_device(jobs, device)
    job_ids = jobs.map(&:id)
    return job_ids if device.blank?

    Job.join_with_suites(job_ids)
       .select { |j| j.device&.downcase&.include?(device.downcase) }
       .map(&:id)
  end

  def self.all_children_jobs(start, limit)
    Job.all.where("command_and_option like '%rerun%'").where(id: start..).order('jobs.id ASC').limit(limit)
  end

  def self.children_jobs(start, limit)
    Job.join_with_suites(
      # `+1` is for getting id which is more than specific id
      Job.all_children_jobs(start + 1, limit).to_a.map(&:id)
    )
  end

  def self.create_job_tree(parent_jobs, children_jobs)
    parent_jobs.each_with_object({}) do |parent_job, job_tree|
      children = children_jobs.select { |cj| parent_job.id == TestReport.get_parent(cj.command_and_option) }.map(&:id)
      job_tree[parent_job.id] = {
        id: parent_job.id, job_start_time: parent_job.start_time, duration: parent_job.duration,
        command_and_option: parent_job.command_and_option, device: parent_job.device,
        service: parent_job.service, category: parent_job.category, children: children
      }
    end
  end

  def self.build_job_list(root_jobs, per_page)
    return [] if root_jobs.empty?

    children = children_jobs(root_jobs.each(&:id).min.id, per_page * 4)
    root_tree = create_job_tree(root_jobs, children)
    children_tree = create_job_tree(children, children)
    merged_tree = root_tree.merge(children_tree)

    jobs = []
    root_jobs.each { |job| traverse_job_tree(merged_tree, job[:id], 0, jobs) }
    jobs
  end

  def self.traverse_job_tree(job_tree, job_id, indent_num, jobs)
    jobs << job_tree[job_id]
    jobs.last[:indent_num] = indent_num
    indent_num += 1
    job_tree[job_id][:children].reverse_each { |child_job_id| traverse_job_tree(job_tree, child_job_id, indent_num, jobs) }
  end
end
