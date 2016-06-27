#!/usr/bin/env bash

. scripts/test_helpers
. ../../../../jobs/rabbitmq-server/templates/post-start.sh

CAPTURED_USERNAME=""
CAPTURED_FILENAME=""

write_username_to_file() {
  CAPTURED_USERNAME=$1
  CAPTURED_FILENAME=$2
}

T_when_username_exists_write_it_to_file() {
  create_management_admin "Alice" "Restaurant"
  expect_to_contain $CAPTURED_USERNAME "Alice"
}
