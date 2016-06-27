#!/usr/bin/env bash

create_management_admin() {
  username=$1
  password=$2

  write_username_to_file $username "some file"
}
