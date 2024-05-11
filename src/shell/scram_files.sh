#!/bin/bash

#################################################################################################################
# Recursively scram files. Gets all files in a path and scrams only the file name, not the whole path nor the   #
# extension                                                                                                     #
#################################################################################################################


function fscramble { #takes a string and scrambles it according to a fixed mapping
    result=$(extscram.sh -k "$1")
    mv "$1" "$result"
}

function _main {
  if [ -z "$1" ]
  then
      echo "No arguments supplied"
      exit
  fi
  fullname="$1"

  if [ -f "$fullname" ] #if argument is a file, scramble its name
  then
      fscramble "$fullname"
  else #if argument is a folder, scramble recursively inside it
      find "$fullname" -depth | while read f #didn't work with for f in "$(find "$fullname" -depth)
      do
    fscramble "$f"
      done
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
