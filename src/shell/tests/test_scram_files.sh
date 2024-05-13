#!/bin/bash

. ../scram_files.sh

setUp() {
  touch file.ext
  touch file
  touch file.
  touch file.ext.ext2
  mkdir -p path/to/
  touch path/to/file.ext.ext2
  touch
}

tearDown() {
  rm elif.ext
  rm elif
  rm elif.
  rm elif.fxt.ext2
#  rm -r taph/
  rm -r path/
}

test_fscramble() {
  SCRAM_CHARS='file' fscramble "file.ext"
  assertEquals "elif.ext" "$result"
  SCRAM_CHARS='file' fscramble "file"
  assertEquals "elif" "$result"
  SCRAM_CHARS='file' fscramble "file."
  assertEquals "elif." "$result"
  SCRAM_CHARS='file' fscramble "file.ext.ext2"
  assertEquals "elif.fxt.ext2" "$result"
  SCRAM_CHARS='pfilet' fscramble "path/to/file.ext.ext2"
  assertEquals "path/to/elif.fxp.ext2" "$result"
}

# Load shUnit2.
. shunit2
