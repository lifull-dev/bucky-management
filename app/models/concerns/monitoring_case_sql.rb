# frozen_string_literal: true

module MonitoringCaseSql
  module_function

  def case_data_template(repo_device)
    <<-SQL.squish
      WITH valid_jobs AS (
        SELECT tcr.job_id FROM test_case_results tcr
        JOIN jobs j ON tcr.job_id = j.id
        WHERE j.command_and_option LIKE ?
          AND j.start_time >= ?
          AND j.start_time < DATE(?) + INTERVAL 1 DAY
        GROUP BY tcr.job_id
        HAVING ROUND(COUNT(CASE WHEN tcr.is_error = 0 THEN 1 END) / COUNT(*), 3) > 0.8
      ),
      valid_results AS (
        SELECT tcr.id, tcr.test_case_id, tcr.is_error, tcr.round, tcr.job_id, j.start_time
        FROM test_case_results tcr JOIN jobs j ON tcr.job_id = j.id
        WHERE j.command_and_option LIKE ? AND tcr.job_id IN (SELECT job_id FROM valid_jobs)
      ),
      latest_r4_fail AS (
        SELECT test_case_id, job_id, start_time,
          ROW_NUMBER() OVER (PARTITION BY test_case_id ORDER BY id DESC) AS rn
        FROM valid_results WHERE round = 4 AND is_error = 1
      ),
      latest_r3_fail AS (
        SELECT test_case_id, job_id, start_time,
          ROW_NUMBER() OVER (PARTITION BY test_case_id ORDER BY id DESC) AS rn
        FROM valid_results WHERE round = 3 AND is_error = 1
      )
      SELECT '#{repo_device}' AS repo_device, tc.case_name,
        CONCAT(ts.github_url, ts.file_path) AS case_url,
        ROUND(COUNT(CASE WHEN vr.is_error = 1 THEN 1 END) / COUNT(*), 3) AS all_round_failrate,
        ROUND(COUNT(CASE WHEN vr.round = 4 AND vr.is_error = 1 THEN 1 END) /
          NULLIF(COUNT(CASE WHEN vr.round = 1 THEN 1 END), 0), 3) AS round4_failrate,
        COALESCE(CAST(r4.job_id AS CHAR), '') AS final_round4_fail_job_id,
        COALESCE(DATE_FORMAT(r4.start_time, '%Y-%m-%d %H:%i'), '') AS final_round4_fail_date,
        COALESCE(CAST(r3.job_id AS CHAR), '') AS final_round3_fail_job_id,
        COALESCE(DATE_FORMAT(r3.start_time, '%Y-%m-%d %H:%i'), '') AS final_round3_fail_date
      FROM valid_results vr
      JOIN test_cases tc ON vr.test_case_id = tc.id
      JOIN test_suites ts ON tc.test_suite_id = ts.id
      LEFT JOIN latest_r4_fail r4 ON r4.test_case_id = tc.id AND r4.rn = 1
      LEFT JOIN latest_r3_fail r3 ON r3.test_case_id = tc.id AND r3.rn = 1
      WHERE ts.device = ?
      GROUP BY tc.id, tc.case_name, ts.file_path, r4.job_id, r4.start_time, r3.job_id, r3.start_time
      ORDER BY round4_failrate DESC, all_round_failrate DESC, tc.case_name
    SQL
  end
end
