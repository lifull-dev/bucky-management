# frozen_string_literal: true

module MonitoringHelper
  def format_passrate(value)
    return '-' if value.nil?

    "#{(value.to_f * 100).round(2)}%"
  end

  def format_failrate(value)
    return '-' if value.nil?

    "#{(value.to_f * 100).round(1)}%"
  end

  # passrate/failrate 값에 따라 CSS 클래스를 반환 (셀 배경색 결정)
  # type: :passrate (기본) 또는 :failrate
  # 호출처: app/views/monitoring/job_data.html.slim, app/views/monitoring/case_data.html.slim
  def rate_class(value, type: :passrate)
    return '' if value.nil?

    rate = value.to_f
    rate = 1.0 - rate if type == :failrate

    if rate >= 1.0
      'has-background-success-light'
    elsif rate >= 0.95
      'has-background-warning-light'
    else
      'has-background-danger-light'
    end
  end
end
