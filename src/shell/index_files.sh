#!/bin/bash

###############################################################################################
# Checks all files and folder in a given path and checks if they're present in an index file. #
# If not, it adds them at the top of the file with a postfix string and new line              #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                                   #
###############################################################################################

function _main {
  if [ -z "$1" ] || [ -z "$2" ]
    then
      echo "Missing arguments"
      echo "Usage:"
      echo "index_files.sh <source path> <index file> [postfix]"
      exit
  fi
  if [ ! -d "$1" ]
    then
      echo "Supplied directory does not exist"
      exit
  fi
    if [ ! -f "$2" ]
    then
      echo "Index file does not exist"
      exit
  fi
  add_to_index "$@"
}

function add_to_index {
  cd "$1"
  for f in *
  do
    echo "checking $f"
    get_name_no_ext "$f"
    name_in_index "$f" $3
  done
}

function get_name_no_ext {
    local xbase="$(basename "$1")" #xbase=${fullname##*/}
    name_noext="${xbase%.*}"
}

function name_in_index {
  local result="$(grep "^$1$3\$" "$2")"
  echo "result $result"
}

function name_postfix_newline {
  echo pass
}

function write_line {
  echo pass
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
