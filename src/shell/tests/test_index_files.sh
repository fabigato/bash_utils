#!/bin/bash

. ../index_files.sh
setUp() {
  mkdir -p root/a/
  mkdir -p root/b/
  touch root/a/filea1.txt
  touch "root/a/filea 2.doc"
  touch root/b/fileb.jpg
  touch root/file.txt
  echo "filea1|||" > index_file.txt
}

tearDown() {
  rm -r root/
  rm index_file.txt
}

test_validext() {
  local extensions="avi,mp4,m4a,mpg"
  local target="./some/path/to/myfile.mp4"
  valid_ext "$target" "$extensions"
  assertTrue 'target file ext mp4 is valid' $?
  local target="myfile.mp3"
  valid_ext "$target" "$extensions"
  assertFalse 'target file ext mp3 is not valid' $?
}

test_integration_folder() {
  _main root index_file.txt "|||" "txt,doc"
  local expected="filea 2|||
file|||
filea1|||"
  assertSame "$expected" "$(cat index_file.txt)"
}

test_integration_folder() {
  _main root/file.txt index_file.txt "|||" "txt,doc"
  local expected="file|||
filea1|||"
  assertSame "$expected" "$(cat index_file.txt)"
}

# Load shUnit2.
. shunit2
