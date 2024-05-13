#!/bin/bash

#################################################################################################################
# Recursively scram files. Gets all files in a path and scrams only the file name, not the whole path nor the   #
# extension                                                                                                     #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                                                     #
#################################################################################################################


function fscramble { #takes a string and scrambles it according to a fixed mapping
    result=$(extscram.sh -k "$1")
    [[ $(realpath "$1") != $(realpath "$result") ]] && mv "$1" "$result"
    printf "$result\n"
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
      export -f fscramble
      find "$fullname" -depth -type f -exec bash -c 'fscramble "{}"' \;
      # find "$fullname" -depth | while read f is bad since the pipe means
      # there is an stdin for exscram.sh so it will read wrong args
      # plus iterating on find's output is bad practice due to special
      # chars in names badly handled
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
