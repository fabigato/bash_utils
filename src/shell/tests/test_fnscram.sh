#!/bin/bash

. ../fnscram.sh
#thispath=$(readlink -f "$0")
#thisfolder="$(dirname $thispath)"
#. "$(dirname $thisfolder)/fnscram.sh"

test_fscramble() {
  result=$(SCRAM_CHARS='file' fscramble "file.ext")
  assertEquals "elif.ext" "$result"
  result=$(SCRAM_CHARS='file' fscramble "file")
  assertEquals "elif" "$result"
  result=$(SCRAM_CHARS='file' fscramble "file.")
  assertEquals "elif." "$result"
  result=$(SCRAM_CHARS='file' fscramble "file.ext.ext2")
  assertEquals "elif.fxt.ext2" "$result"
}

test_fscramble_whole_path() {
  result=$(SCRAM_CHARS='file' fscramble_whole_path "file.ext")
  assertEquals "$result" "elif.ext"
  result=$(SCRAM_CHARS='file' fscramble_whole_path "file")
  assertEquals "$result" "elif"
  result=$(SCRAM_CHARS='file' fscramble_whole_path "file.")
  assertEquals "$result" "elif."
  result=$(SCRAM_CHARS='file' fscramble "file.ext.ext2")
  assertEquals "elif.fxt.ext2" "$result"
  result=$(SCRAM_CHARS='pfilet' fscramble_whole_path "path/to/file.ext")
  assertEquals "$result" "taph/po/elif.ext"
}

# Load shUnit2.
. shunit2
