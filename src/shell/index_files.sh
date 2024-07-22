#!/bin/bash

########################################################################################
# For each file with a given extension in a given path, checks if they're present in   #
# an index file. If not, it adds them at the top of the file with a postfix string and #
# new line                                                                             #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                            #
########################################################################################

function _main {
  if [ -z "$1" ] || [ -z "$2" ]
    then
      echo "Missing arguments"
      echo "Usage:"
      echo "index_files.sh <source path or file> <index file> [postfix] [valid_extensions,...]"
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
  target="$1"
  if [ -z $4 ]
  then
    list="mp4,mp3,m4a"
  else
    list=$4
  fi

  if [ -f "$target" ] #if argument is a file, scramble its name
  then
      process_file "$target"
  else #if argument is a folder, scramble recursively inside it
      export -f process_file
      # find "$target" -depth -type f -exec bash -c 'fscramble "{}"' \;
      find "$target" -depth -exec bash -c 'process_file "{}" "$list"' \;
      # find "$target" -depth | while read f is bad since the pipe means
      # there is an stdin for exscram.sh so it will read wrong args
      # plus iterating on find's output is bad practice due to special
      # chars in names badly handled
  fi
}

function valid_ext {
  local target=$1
  local extensions=$2
  local target="$(basename "$target")"
  local ext=$([[ $target = *.* ]] && printf %s "${target##*.}" || printf '')
  echo $extensions | tr "," '\n' | grep -F -q -x "$ext"
}

function process_file {
  local target=$1
  echo pass
#  if valid_ext
#  get_name_no_ext "$target"
#  name_in_index "$name_noext" $3
}

function get_name_no_ext {
    local xbase="$(basename "$1")"
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
