#!/bin/bash

. ../scram.sh

test_scram() {
  result=$(scramble_line "some line" 'sefz')
  assertEquals "zomf linf" "$result"
  result=$(scramble_line "some line")  # no scram chars -> no scram
  assertEquals "some line" "$result"
}

# Load shUnit2.
. shunit2