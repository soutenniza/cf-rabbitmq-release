#!/usr/bin/env bash

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1091
. unit_test/test_helpers

export BASE_PATH="$PWD/jobs/rabbitmq-server/templates/commands"
# shellcheck disable=SC1090
. "$BASE_PATH/post-start"

T_when_rabbitmq_starts_within_expected_period() {
  local actual expected

  expected="RabbitMQ app is running"
  actual="$(
    exit_if_rabbitmq_app_not_running_in_seconds 0.1 true
  )"

  expect_to_equal "$actual" "$expected" || $T_fail
}

T_when_rabbitmq_app_does_not_start_within_expected_period() {
  local actual expected

  expected="RabbitMQ app is not running after 0.1 seconds"
  actual="$(
    exit_if_rabbitmq_app_not_running_in_seconds 0.1 false
  )"

  expect_to_equal "$actual" "$expected" || $T_fail
}
