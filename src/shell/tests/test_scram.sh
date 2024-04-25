#!/bin/bash

. ../scram.sh

test_scram() {
  result=$(scramble_line "some line" 'sefz')
  assertEquals "$result" "zomf linf"
  result=$(scramble_line "some line")  # no scram chars -> no scram
  assertEquals "$result" "some line"
}

# Load shUnit2.
. shunit2