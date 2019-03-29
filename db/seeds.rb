# frozen_string_literal: true

require 'date'

1.times do |_i|
  Job.create(
    start_time: Time.now
  )
  sleep(5)
end

JOB_ID = 1

# one test suite
1.upto(4) do |j|
  TestCaseResult.create(
    test_case_id: 1,
    error_title: "error5555 title#{j}",
    error_message: "error5555 message#{j}",
    elapsed_time: 50,
    is_error: 0,
    job_id:   JOB_ID,
    round: j
  )
end

1.upto(2) do |j|
  TestCaseResult.create(
    test_case_id: 2,
    error_title: "error5555 title#{j}",
    error_message: "error5555 message#{j}",
    elapsed_time: 250,
    is_error: 1,
    job_id:   JOB_ID,
    round: j
  )
end

TestCaseResult.create(
  test_case_id: 2,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 120,
  is_error: 0,
  job_id:   JOB_ID,
  round: 3
)

TestCaseResult.create(
  test_case_id: 3,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 50,
  is_error: 0,
  job_id:   JOB_ID,
  round: 1
)
# one test suite
1.upto(3) do |j|
  TestCaseResult.create(
    test_case_id: 4,
    error_title: "error5555 title#{j}",
    error_message: "error5555 message#{j}",
    elapsed_time: 50,
    is_error: 1,
    job_id:   JOB_ID,
    round: j
  )
end

TestCaseResult.create(
  test_case_id: 4,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 50,
  is_error: 0,
  job_id:   JOB_ID,
  round: 4
)

1.upto(2) do |j|
  TestCaseResult.create(
    test_case_id: 5,
    error_title: "error5555 title#{j}",
    error_message: "error5555 message#{j}",
    elapsed_time: 250,
    is_error: 1,
    job_id:   JOB_ID,
    round: j
  )
end

TestCaseResult.create(
  test_case_id: 5,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 120,
  is_error: 0,
  job_id:   JOB_ID,
  round: 3
)

1.upto(4) do |j|
  TestCaseResult.create(
    test_case_id: 6,
    error_title: "error5555 title#{j}",
    error_message: "error5555 message#{j}",
    elapsed_time: 50,
    is_error: 0,
    job_id:   JOB_ID,
    round: j
  )
end

# one test suite
TestCaseResult.create(
  test_case_id: 8,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 50,
  is_error: 0,
  job_id:   JOB_ID,
  round: 1
)

TestCaseResult.create(
  test_case_id: 9,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 250,
  is_error: 1,
  job_id:   JOB_ID,
  round: 1
)

TestCaseResult.create(
  test_case_id: 9,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 120,
  is_error: 0,
  job_id:   JOB_ID,
  round: 2
)

TestCaseResult.create(
  test_case_id: 10,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 50,
  is_error: 0,
  job_id:   JOB_ID,
  round: 1
)
# one test suite
1.upto(3) do |j|
  TestCaseResult.create(
    test_case_id: 11,
    error_title: "error5555 title#{j}",
    error_message: "error5555 message#{j}",
    elapsed_time: 50,
    is_error: 1,
    job_id:   JOB_ID,
    round: j
  )
end

TestCaseResult.create(
  test_case_id: 11,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 50,
  is_error: 0,
  job_id:   JOB_ID,
  round: 4
)

TestCaseResult.create(
  test_case_id: 12,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 250,
  is_error: 1,
  job_id:   JOB_ID,
  round: 1
)

TestCaseResult.create(
  test_case_id: 12,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 120,
  is_error: 0,
  job_id:   JOB_ID,
  round: 2
)

TestCaseResult.create(
  test_case_id: 13,
  error_title: "error5555 title#{j}",
  error_message: "error5555 message#{j}",
  elapsed_time: 50,
  is_error: 0,
  job_id:   JOB_ID,
  round: 1
)
