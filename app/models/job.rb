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

  def self.searched_root_jobs(search_word)
    all_root_jobs.where('command_and_option LIKE ?', "%#{search_word}%")
  end

  def self.searched_root_jobs_per_page(start_num, per_page, search_word)
    Job.join_with_suites(Job.all_root_jobs
            .searched_root_jobs(search_word)
            .select(&:id)[start_num...start_num + per_page])
  end

  def self.root_jobs(start_num, per_page)
    Job.join_with_suites(Job.all_root_jobs.to_a
        .map(&:id)[start_num...start_num + per_page])
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
    job_tree = {}
    parent_jobs.each do |parent_job|
      job_tree[parent_job.id] = {
        id: parent_job.id,
        job_start_time: parent_job.start_time,
        command_and_option: parent_job.command_and_option,
        device: parent_job.device,
        service: parent_job.service,
        category: parent_job.category,
        total_time: parent_job.total_time,
        children: []
      }

      children_jobs.each do |child_job|
        job_tree[parent_job.id][:children] << child_job.id if parent_job.id == TestReport.get_parent(child_job.command_and_option)
      end
    end

    job_tree
  end
end
