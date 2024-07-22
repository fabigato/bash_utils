#!/bin/bash

. ../index_files.sh

test_validext() {
  local extensions="avi,mp4,m4a,mpg"
  local target="./some/path/to/myfile.mp4"
  valid_ext "$target" "$extensions"
  assertTrue 'target file ext mp4 is valid' $?
}

# Load shUnit2.
. shunit2
