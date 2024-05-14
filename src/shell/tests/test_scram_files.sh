#!/bin/bash

. ../scram_files.sh

setUp() {
  touch file.ext
  touch file
  touch file.
  touch file.ext.ext2
  mkdir -p path/a/
  mkdir -p path/b/
  touch path/a/filea.exta.ext2
  touch path/b/fileb.extb.ext2
}

tearDown() {
  rm -f file.ext
  rm -f file
  rm -f file.
  rm -f file.ext.ext2
  rm -f elif.ext
  rm -f elif
  rm -f elif.
  rm -f elif.fxt.ext2
  rm -rf pzth/
  rm -rf path/
}

test_fscramble() {
  SCRAM_CHARS='file' fscramble "file.ext" 1>/dev/null
  assertEquals "elif.ext" "$result"
  SCRAM_CHARS='file' fscramble "file" 1>/dev/null
  assertEquals "elif" "$result"
  SCRAM_CHARS='file' fscramble "file." 1>/dev/null
  assertEquals "elif." "$result"
  SCRAM_CHARS='file' fscramble "file.ext.ext2" 1>/dev/null
  assertEquals "elif.fxt.ext2" "$result"
  SCRAM_CHARS='az' fscramble "path/a/filea.exta.ext2" 1>/dev/null
  assertEquals "path/a/filez.extz.ext2" "$result"
}

test_fscramble_recursive() {
  SCRAM_CHARS='abwz' fscramble_recursive "path" 1>/dev/null
  assertTrue 'OK' "[ -r pzth/z/filez.extz.ext2 ]"
  assertTrue 'OK' "[ -r pzth/w/filew.extw.ext2 ]"
}

# Load shUnit2.
. shunit2
