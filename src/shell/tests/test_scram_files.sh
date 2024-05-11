#!/bin/bash

. ../scram_files.sh

setUp() {
  touch file.ext
  touch file
  touch file.
  touch file.ext.ext2
  mkdir -p path/to/
  touch path/to/file.ext.ext2
}

tearDown() {
  rm elif.ext
  rm elif
  rm elif.
  rm elif.fxt.ext2
  rm -r path/*
  rmdir path
}

test_fscramble() {
  SCRAM_CHARS='file' fscramble "file.ext"
  assertEquals "./elif.ext" "$destination"
  SCRAM_CHARS='file' fscramble "file"
  assertEquals "./elif" "$destination"
  SCRAM_CHARS='file' fscramble "file."
  assertEquals "./elif." "$destination"
  SCRAM_CHARS='file' fscramble "file.ext.ext2"
  assertEquals "./elif.fxt.ext2" "$destination"
  SCRAM_CHARS='pfilet' fscramble "path/to/file.ext.ext2"
  assertEquals "path/to/elif.fxp.ext2" "$destination"
}

# Load shUnit2.
. shunit2
