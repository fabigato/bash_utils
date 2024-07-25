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
  if [ -f "$target" ] #if argument is a file, scramble its name
  then
      process_file "$target" "$index_file" "$postfix" "$extensions"
  else #if argument is a folder, scramble recursively inside it
      export -f process_file
      export -f valid_ext
      export -f get_name_no_ext
      export -f name_in_index
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
  local target=$1
  local index_file="$2"
  local postfix="$3"
  local extensions=$4
  if valid_ext $target $extensions
  then
    get_name_no_ext "$target"
    if ! name_in_index "$name_noext" "$index_file" "$postfix"
    then
      echo "writing $name_noext to $index_file"
      echo -e "$name_noext$postfix\n$(cat "$index_file")" > "$index_file"
    fi
  fi
}

function get_name_no_ext {
  local target="$1"
  local xbase="$(basename "$target")"
  name_noext="${xbase%.*}"
}

function name_in_index {
  local target="$1"
  local index_file="$2"
  local postfix="$3"
  grep "^$target$postfix\$" "$index_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
