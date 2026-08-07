# frozen_string_literal: true

class EtrmController < ApplicationController
  DEFAULT_DAYS = 7

  def index
    redirect_to etrm_job_data_path
  end

  def job_data
    set_date_range

    @job_data = fetch_job_data(@start_date, @end_date)
    @job_summary = calculate_job_summary(@job_data)

    # repo_device別にページネーション (Kaminari使用)
    @per_page = 10
    @pages = {}
    @job_data.group_by { |row| row['repo_device'] }.each do |device, rows|
      page = (params["page_#{device}"] || 1).to_i
      @pages[device] = Kaminari.paginate_array(rows).page(page).per(@per_page)
    end
  end

  def case_data
    # 전체 케이스 검색 (기간 제한 없음)
    @search_value = params[:search_value]
    @case_data = fetch_case_data_all

    # 검색어가 있으면 필터링
    if @search_value.present?
      @case_data = @case_data.select { |row| row['case_name'].include?(@search_value) }
    end

    # repo_device別にページネーション (Kaminari使用)
    @per_page = 10
    @pages = {}
    @case_data.group_by { |row| row['repo_device'] }.each do |device, rows|
      page = (params["page_#{device}"] || 1).to_i
      @pages[device] = Kaminari.paginate_array(rows).page(page).per(@per_page)
    end
  end

  private

  def set_date_range
    @end_date = params[:date_to].present? ? Date.parse(params[:date_to]) : Date.today
    @start_date = params[:date_from].present? ? Date.parse(params[:date_from]) : @end_date - (DEFAULT_DAYS - 1).days
  end

  def repo_mapping
    @repo_mapping ||= JSON.parse(
      ENV.fetch('REPO_MAPPING', '{}')
    )
  end

  def repo_targets
    # REPO_MAPPINGのキーをLIKE検索パターンとして、DBのdeviceと組み合わせる
    targets = []
    repo_mapping.each do |command_key, repo_name|
      devices = TestSuite.where(test_category: 'e2e').distinct.pluck(:device)
      devices.each do |device|
        targets << {
          name: "#{repo_name}_#{device}",
          command: "%#{command_key}%",
          device: device
        }
      end
    end
    targets
  end

  def calculate_job_summary(job_data)
    summary = {}
    grouped = job_data.group_by { |row| row['repo_device'] }

    grouped.each do |device, rows|
      valid_rows = rows.select { |r| r['passrate_round1'].to_f > 0.8 }
      next if valid_rows.empty?

      summary[device] = {
        valid_count: valid_rows.size,
        avg_passrate_round1: (valid_rows.sum { |r| r['passrate_round1'].to_f } / valid_rows.size).round(4),
        avg_passrate_round2: (valid_rows.sum { |r| r['passrate_round2'].to_f } / valid_rows.size).round(4),
        avg_passrate_round3: (valid_rows.sum { |r| r['passrate_round3'].to_f } / valid_rows.size).round(4),
        avg_passrate_round4: (valid_rows.sum { |r| r['passrate_round4'].to_f } / valid_rows.size).round(4)
      }
    end

    summary
  end

  def fetch_job_data(start_date, end_date)
    results = []
    repo_targets.each do |target|
      rows = ActiveRecord::Base.connection.select_all(
        sanitize_job_query(target[:name], target[:command], target[:device], start_date, end_date)
      )
      results.concat(rows.to_a)
    end
    results
  end

  def fetch_case_data_all
    # 기간 제한 없이 전체 케이스 데이터 조회
    results = []
    repo_targets.each do |target|
      rows = ActiveRecord::Base.connection.select_all(
        sanitize_case_query_all(target[:name], target[:command], target[:device])
      )
      results.concat(rows.to_a)
    end
    results
  end

  def sanitize_job_query(repo_device, command_filter, device_filter, start_date, end_date)
    ActiveRecord::Base.sanitize_sql_array([<<-SQL.squish, command_filter, device_filter, start_date, end_date])
      SELECT
          '#{repo_device}' AS repo_device,
          tcr.job_id,
          REGEXP_SUBSTR(j.base_fqdn, '[0-9]+') AS pr_number,
          DATE_FORMAT(j.start_time, '%Y/%m/%d') AS date,
          DATE_FORMAT(j.start_time, '%H:%i') AS start_time,
          CASE
            WHEN j.end_time IS NOT NULL THEN TIME_FORMAT(TIMEDIFF(j.end_time, j.start_time), '%H:%i:%s')
            ELSE NULL
          END AS duration,
          ROUND(
              COUNT(DISTINCT CASE WHEN tcr.round = 1 AND tcr.is_error = 0 THEN tcr.test_case_id END) /
              COUNT(DISTINCT tcr.test_case_id), 4
          ) AS passrate_round1,
          ROUND(
              COUNT(DISTINCT CASE WHEN tcr.round <= 2 AND tcr.is_error = 0 THEN tcr.test_case_id END) /
              COUNT(DISTINCT tcr.test_case_id), 4
          ) AS passrate_round2,
          ROUND(
              COUNT(DISTINCT CASE WHEN tcr.round <= 3 AND tcr.is_error = 0 THEN tcr.test_case_id END) /
              COUNT(DISTINCT tcr.test_case_id), 4
          ) AS passrate_round3,
          ROUND(
              COUNT(DISTINCT CASE WHEN tcr.round <= 4 AND tcr.is_error = 0 THEN tcr.test_case_id END) /
              COUNT(DISTINCT tcr.test_case_id), 4
          ) AS passrate_round4
      FROM
          test_case_results tcr
      JOIN jobs j ON tcr.job_id = j.id
      JOIN test_cases tc ON tcr.test_case_id = tc.id
      JOIN test_suites ts ON tc.test_suite_id = ts.id
      WHERE
          j.command_and_option LIKE ?
          AND ts.device = ?
          AND j.start_time >= ?
          AND j.start_time < DATE(?) + INTERVAL 1 DAY
      GROUP BY
          tcr.job_id, j.base_fqdn, j.start_time, j.end_time
      HAVING
          ROUND(
              COUNT(DISTINCT CASE WHEN tcr.round = 1 AND tcr.is_error = 0 THEN tcr.test_case_id END) /
              COUNT(DISTINCT tcr.test_case_id), 4
          ) > 0.8
      ORDER BY
          j.start_time DESC, tcr.job_id
    SQL
  end

  def sanitize_case_query_all(repo_device, command_filter, device_filter)
    # 기간 제한 없는 케이스 쿼리
    ActiveRecord::Base.sanitize_sql_array([<<-SQL.squish, command_filter, command_filter, device_filter])
      WITH valid_jobs AS (
          SELECT tcr.job_id
          FROM test_case_results tcr
          JOIN jobs j ON tcr.job_id = j.id
          WHERE j.command_and_option LIKE ?
          GROUP BY tcr.job_id
          HAVING ROUND(COUNT(CASE WHEN tcr.is_error = 0 THEN 1 END) / COUNT(*), 3) > 0.8
      ),
      valid_results AS (
          SELECT tcr.id, tcr.test_case_id, tcr.is_error, tcr.round, tcr.job_id, j.start_time
          FROM test_case_results tcr
          JOIN jobs j ON tcr.job_id = j.id
          WHERE j.command_and_option LIKE ?
            AND tcr.job_id IN (SELECT job_id FROM valid_jobs)
      ),
      latest_r4_fail AS (
          SELECT test_case_id, job_id, start_time,
                 ROW_NUMBER() OVER (PARTITION BY test_case_id ORDER BY id DESC) AS rn
          FROM valid_results
          WHERE round = 4 AND is_error = 1
      ),
      latest_r3_fail AS (
          SELECT test_case_id, job_id, start_time,
                 ROW_NUMBER() OVER (PARTITION BY test_case_id ORDER BY id DESC) AS rn
          FROM valid_results
          WHERE round = 3 AND is_error = 1
      )
      SELECT
          '#{repo_device}' AS repo_device,
          tc.case_name,
          CONCAT(ts.github_url, ts.file_path) AS case_url,
          ROUND(COUNT(CASE WHEN vr.is_error = 1 THEN 1 END) / COUNT(*), 3) AS all_round_failrate,
          ROUND(
              COUNT(CASE WHEN vr.round = 4 AND vr.is_error = 1 THEN 1 END) /
              NULLIF(COUNT(CASE WHEN vr.round = 1 THEN 1 END), 0), 3
          ) AS round4_failrate,
          COALESCE(CAST(r4.job_id AS CHAR), '') AS final_round4_fail_job_id,
          COALESCE(DATE_FORMAT(r4.start_time, '%Y-%m-%d %H:%i'), '') AS final_round4_fail_date,
          COALESCE(CAST(r3.job_id AS CHAR), '') AS final_round3_fail_job_id,
          COALESCE(DATE_FORMAT(r3.start_time, '%Y-%m-%d %H:%i'), '') AS final_round3_fail_date
      FROM
          valid_results vr
      JOIN test_cases tc ON vr.test_case_id = tc.id
      JOIN test_suites ts ON tc.test_suite_id = ts.id
      LEFT JOIN latest_r4_fail r4 ON r4.test_case_id = tc.id AND r4.rn = 1
      LEFT JOIN latest_r3_fail r3 ON r3.test_case_id = tc.id AND r3.rn = 1
      WHERE
          ts.device = ?
      GROUP BY
          tc.id, tc.case_name, ts.file_path,
          r4.job_id, r4.start_time, r3.job_id, r3.start_time
      ORDER BY
          round4_failrate DESC, all_round_failrate DESC, tc.case_name
    SQL
  end
end
