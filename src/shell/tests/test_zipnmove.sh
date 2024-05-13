#!/bin/bash

. ../zipnmove.sh

setUp() {
  mkdir -p target
  mkdir -p zips
  mkdir -p originals
  touch target/file1.ext
  touch target/file2.ext
}

tearDown() {
  rm -r target/
  rm -r zips/
  rm -r originals/
}

test_zipnmove(){
  SCRAM_CHARS='file' zipnmove target zips originals secret
  assertTrue 'OK' "[ -r zips/elif1.zip ]"
  assertTrue 'OK' "[ -r zips/elif2.zip ]"
  assertTrue 'OK' "[ -r originals/file1.ext ]"
  assertTrue 'OK' "[ -r originals/file2.ext ]"
  # test zip content is correct and with the right password
  unzip_result="$(unzip -t -P secret zips/elif1.zip)"
  assertSame "elif1.ext OK" "$(echo $unzip_result | cut -d ' ' -f 4,5)"
  unzip_result="$(unzip -t -P secret zips/elif2.zip)"
  assertSame "elif2.ext OK" "$(echo $unzip_result | cut -d ' ' -f 4,5)"
}

# Load shUnit2.
. shunit2
