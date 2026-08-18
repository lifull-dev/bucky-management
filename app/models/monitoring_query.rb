# frozen_string_literal: true

class MonitoringQuery
  extend MonitoringJobSql
  extend MonitoringCaseSql

  class << self
    def fetch_job_data(start_date, end_date)
      repo_targets.flat_map do |target|
        execute_query(job_data_sql(target, start_date, end_date))
      end
    end

    def fetch_case_data(start_date, end_date)
      repo_targets.flat_map do |target|
        execute_query(case_data_sql(target, start_date, end_date))
      end
    end

    def calculate_job_summary(job_data)
      job_data.group_by { |row| row['repo_device'] }.each_with_object({}) do |(device, rows), summary|
        valid_rows = rows.select { |r| r['passrate_round1'].to_f > 0.8 }
        next if valid_rows.empty?

        summary[device] = build_summary_stats(valid_rows)
      end
    end

    private

    def execute_query(sql)
      ActiveRecord::Base.connection.select_all(sql).to_a
    end

    def repo_mapping
      @repo_mapping ||= JSON.parse(ENV.fetch('REPO_MAPPING', '{}'))
    end

    def repo_targets
      devices = TestSuite.where(test_category: 'e2e').distinct.pluck(:device)

      repo_mapping.flat_map do |command_key, repo_name|
        devices.map { |device| { name: "#{repo_name}_#{device}", command: "%#{command_key}%", device: device } }
      end
    end

    def build_summary_stats(rows)
      {
        valid_count: rows.size,
        avg_passrate_round1: calc_avg(rows, 'passrate_round1'),
        avg_passrate_round2: calc_avg(rows, 'passrate_round2'),
        avg_passrate_round3: calc_avg(rows, 'passrate_round3'),
        avg_passrate_round4: calc_avg(rows, 'passrate_round4')
      }
    end

    def calc_avg(rows, col)
      (rows.sum { |r| r[col].to_f } / rows.size).round(4)
    end

    def job_data_sql(target, start_date, end_date)
      binds = {
        repo_device: target[:name],
        command_filter: target[:command],
        device_filter: "%-D #{target[:device]}%",
        start_date: start_date,
        end_date: end_date
      }
      ActiveRecord::Base.sanitize_sql_array([job_data_template, binds])
    end

    def case_data_sql(target, start_date, end_date)
      binds = {
        repo_device: target[:name],
        command_filter: target[:command],
        device_filter: target[:device],
        start_date: start_date,
        end_date: end_date,
        max_records: 25_000
      }
      ActiveRecord::Base.sanitize_sql_array([case_data_template, binds])
    end
  end
end
