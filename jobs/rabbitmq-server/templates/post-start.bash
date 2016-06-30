#!/bin/bash -ex

BASE_PATH="${BASE_PATH:-/var/vcap/jobs/rabbitmq-server/bin/commands}"

# shellcheck disable=SC1090
. "$BASE_PATH/post-start"

main() {
  exit_if_rabbitmq_app_not_running_in_seconds 30
  rabbitmq_create_user "foo" "foo" || true
}

main
