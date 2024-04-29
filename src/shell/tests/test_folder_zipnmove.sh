#!/bin/bash

. ../folder_zipnmove.sh
setUp() {
  echo "sono a $(pwd)"
  mkdir -p root/a/
  mkdir -p root/b/
  touch root/a/filea1
  touch root/a/filea2
  touch root/b/fileb1
  mkdir -p zips
  mkdir -p files
  tree root
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
}

# Load shUnit2.
. shunit2
# scramfolder_zip_and_move root
