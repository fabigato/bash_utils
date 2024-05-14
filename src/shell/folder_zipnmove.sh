#!/bin/bash

##########################################################################################
# zips every folder in a given path in its own zip archive.                              #
# Every zipped file will have a name identical to the path it zipped plus.zip extension. #
# Prompts for a password to encrypt every zip file with                                  #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                              #
##########################################################################################

#######basic checks#######
function _main {
  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
    then
      echo "No arguments supplied"
      echo "Usage:"
      echo "zipper.sh <to-process> <zip-dest> <original-dest>"
      exit
  fi
  if [ ! -d "$1" ] || [ ! -d "$2" ] || [ ! -d "$3" ]
    then
      echo "Supplied directory does not exist"
      exit
  fi
  echo "Enter password..."
  read -s password
  echo "Repeat password..."
  read -s password2
  if [ "$password" != "$password2" ]
  then
    echo "Passwords don't match"
    exit
  fi
  loop_scramfolder_zip_and_move "$@" "$password"
}
#######actual script######
function scramfolder_zip_and_move {
  local startingpoint="$(pwd)"
  scrambled=$(extscram.sh -k "$1")
  scram_files.sh "$1"
  cd "$scrambled"
  local current="$(pwd)"
  local parent=$(basename "$current")
  zipfile="$parent.zip"
  zip -r -P "$4" "$startingpoint/$zipfile" .
  cd "$startingpoint"
}

function move {
  # handle both relative and absolute mv destinations
  # usage:
  # move file-to-move destination root
  # where root is prepended to destination if destination is not absolute
  case $2 in
    /*) mv "$1" "$2" ;;  # zip destination is absolute
    *)  mv "$1" "$3/$2" ;;  # zip destination is relative
  esac
}

function loop_scramfolder_zip_and_move {
  local startingpoint="$(pwd)"
  cd "$1"
  local password="$4"
  for f in */
  do
    scramfolder_zip_and_move "$f" "$2" "$3", "$password"
    move "$zipfile" "$2" "$startingpoint"
    move "$scrambled" "$3" "$startingpoint"

  done
  cd "$startingpoint"
  echo "done"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
