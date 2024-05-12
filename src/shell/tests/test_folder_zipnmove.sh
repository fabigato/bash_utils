#!/bin/bash

. ../folder_zipnmove.sh
setUp() {
  mkdir -p root/a/
  mkdir -p root/b/
  touch root/a/filea1
  touch root/a/filea2
  touch root/b/fileb1
  mkdir -p zips
  mkdir -p files
}

tearDown() {
  rm -r root/*
  rm -r zips/*
  rm -r files/*
  rmdir root/
  rmdir zips/
  rmdir files/
}

test_scramfolder_zip_and_move() {
  SCRAM_CHARS='az' scramfolder_zip_and_move root/a zips files secret
  assertTrue 'OK' "[ -r zips/z.zip ]"
  assertTrue 'OK' "[ -r files/z/filez1 ]"
  assertTrue 'OK' "[ -r files/z/filez2 ]"
}

# Load shUnit2.
. shunit2
# scramfolder_zip_and_move root
