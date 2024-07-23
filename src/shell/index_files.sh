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
  local target="$1"
  local index_file="$2"
  local postfix="$3"
  if [ -z $4 ]
  then
    local extensions="mp4,mp3,m4a"
  else
    local extensions=$4
  fi
  echo "we zijn in add_to_index met args $1 $2 $3 en $4"
  if [ -f "$target" ] #if argument is a file, scramble its name
  then
      process_file "$target" "$index_file" "$postfix" "$extensions"
  else #if argument is a folder, scramble recursively inside it
      export -f process_file
      export -f valid_ext
#      export "$index_file"
#      export "$postfix"
#      export "$extensions"
      find "$target" -depth -exec bash -c 'process_file $1 $2 $3 $4' bash {} "$index_file" "$postfix" "$extensions" \;
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
  echo "we zijn in process_file met args $@"
  local target=$1
  local extensions=$2
  if valid_ext $target $extensions
  then
    get_name_no_ext "$target"
#  name_in_index "$name_noext" $3
  fi
}

function get_name_no_ext {
    local xbase="$(basename "$1")"
    name_noext="${xbase%.*}"
}

function name_in_index {
  local target="$1"
  local result='$(grep "^$1$3\$" "$2")'
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
