#!/bin/bash
# set -e
##########################################################################################
# zips every file (not folder) in a given folder in its own zip archive. Every zipped    #
# file will have a name identical to the file it contains except for the extension (if   #
# present) that would be .zip instead.                                                   #
# Every zipped file will have a name identical to the file it zipped with .zip extension.#
# Prompts for a password to encrypt every zip file with                                  #
# Usage: "zipnmove.sh <to-process> <zip-dest> <original-dest>"                           #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                              #
##########################################################################################


function _main {
  #######basic checks#######
  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
    then
      echo "No arguments supplied"
      echo "Usage:"
      echo "zipnmove.sh <to-process> <zip-dest> <original-dest>"
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
  zipnmove "$@" $password
}

function move {
  # mv with a check for relative and absolute paths
  # usage: move origin destination prefix
  if [[ "$2" =~ ^"/" ]]; then
    mv "$1" "$2"
  else  # target is relative, prepend prefix
    mv "$1" "$3/$2"
  fi
}

#######actual script######
function zipnmove {
  # usage: zipnmove targetfolder zip-dest original-dest password
  local startingpoint="$(pwd)"
  cd "$1"

  for f in ./*
  do
    if [ -f "$f" ]; then
      echo "processing $f"
      scrambled=$(extscram.sh -k "$f")
      scram_files.sh "$f"
      local filename="$(basename "$scrambled")"
      local filenamenoext="${filename%.*}"
      zip -P "$4" "$filenamenoext.zip" "$filename"
      move "$filenamenoext.zip" "$2" "$startingpoint"
      scram_files.sh "$scrambled"
      move "$f" "$3" "$startingpoint"
    fi
  done
  cd "$startingpoint"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
