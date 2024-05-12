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
  scramfolder_zip_and_move root/a zips files secret
  assertTrue 'OK' "[ -r zips/s.zip ]"
}

# Load shUnit2.
. shunit2
# scramfolder_zip_and_move root
