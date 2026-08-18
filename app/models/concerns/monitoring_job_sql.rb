# frozen_string_literal: true

module MonitoringJobSql
  module_function

  def job_data_template
    <<-SQL.squish
      SELECT :repo_device AS repo_device, tcr.job_id,
        REGEXP_SUBSTR(j.base_fqdn, '[0-9]+') AS pr_number,
        DATE_FORMAT(j.start_time, '%Y/%m/%d') AS date,
        DATE_FORMAT(j.start_time, '%H:%i') AS start_time,
        CASE WHEN j.end_time IS NOT NULL
          THEN TIME_FORMAT(TIMEDIFF(j.end_time, j.start_time), '%H:%i:%s') ELSE NULL END AS duration,
        ROUND(COUNT(DISTINCT CASE WHEN tcr.round = 1 AND tcr.is_error = 0
          THEN tcr.test_case_id END) / COUNT(DISTINCT tcr.test_case_id), 4) AS passrate_round1,
        ROUND(COUNT(DISTINCT CASE WHEN tcr.round <= 2 AND tcr.is_error = 0
          THEN tcr.test_case_id END) / COUNT(DISTINCT tcr.test_case_id), 4) AS passrate_round2,
        ROUND(COUNT(DISTINCT CASE WHEN tcr.round <= 3 AND tcr.is_error = 0
          THEN tcr.test_case_id END) / COUNT(DISTINCT tcr.test_case_id), 4) AS passrate_round3,
        ROUND(COUNT(DISTINCT CASE WHEN tcr.round <= 4 AND tcr.is_error = 0
          THEN tcr.test_case_id END) / COUNT(DISTINCT tcr.test_case_id), 4) AS passrate_round4
      FROM test_case_results tcr
      JOIN jobs j ON tcr.job_id = j.id
      WHERE j.command_and_option LIKE :command_filter
        AND j.command_and_option LIKE :device_filter
        AND j.duration IS NOT NULL
        AND j.start_time >= :start_date
        AND j.start_time < DATE(:end_date) + INTERVAL 1 DAY
      GROUP BY tcr.job_id, j.base_fqdn, j.start_time, j.end_time
      HAVING ROUND(COUNT(DISTINCT CASE WHEN tcr.round = 1 AND tcr.is_error = 0
        THEN tcr.test_case_id END) / COUNT(DISTINCT tcr.test_case_id), 4) > 0.8
      ORDER BY j.start_time DESC, tcr.job_id
    SQL
  end
end
