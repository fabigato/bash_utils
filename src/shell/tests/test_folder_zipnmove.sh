#!/bin/bash

. ../folder_zipnmove.sh

testEquality() {
  scramble_line
  assertEquals 1 1
}

# Load shUnit2.
. shunit2