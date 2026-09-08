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

  def failrate_class(value)
    return '' if value.nil?

    rate = value.to_f * 100

    if rate >= 90
      'failrate-critical'
    elsif rate >= 60
      'failrate-high'
    elsif rate >= 30
      'failrate-medium'
    else
      'failrate-low'
    end
  end
end
