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
  rm -r root/
  rm -r zips/
  rm -r files/
}

#test_scramfolder_zip_and_move() {
#  SCRAM_CHARS='az' scramfolder_zip_and_move root/a zips files secret
#  assertTrue 'OK' "[ -r zips/z.zip ]"
#  assertTrue 'OK' "[ -r files/z/filez1 ]"
#  assertTrue 'OK' "[ -r files/z/filez2 ]"
#  # test zip content is correct and with the right password
#  unzip_result="$(unzip -t -P secret zips/z.zip)"
#  assertSame "filez1 OK" "$(echo $unzip_result | cut -d ' ' -f 4,5)"
#  assertSame "filez2 OK" "$(echo $unzip_result | cut -d ' ' -f 7,8)"
#}

test_loop_scramfolder_zip_and_move(){
  SCRAM_CHARS='az' loop_scramfolder_zip_and_move root zips files secret
  assertTrue 'OK' "[ -r zips/z.zip ]"
  assertTrue 'OK' "[ -r files/z/filez1 ]"
  assertTrue 'OK' "[ -r files/z/filez2 ]"
  assertTrue 'OK' "[ -r zips/b.zip ]"
  assertTrue 'OK' "[ -r files/b/fileb1 ]"
  # test zip content is correct and with the right password
  unzip_result="$(unzip -t -P secret zips/z.zip)"
  assertSame "filez1 OK" "$(echo $unzip_result | cut -d ' ' -f 4,5)"
  assertSame "filez2 OK" "$(echo $unzip_result | cut -d ' ' -f 7,8)"
  unzip_result="$(unzip -t -P secret zips/b.zip)"
  assertSame "fileb1 OK" "$(echo $unzip_result | cut -d ' ' -f 4,5)"
}

# Load shUnit2.
. shunit2
# scramfolder_zip_and_move root
