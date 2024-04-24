#!/bin/bash
#zips every folder in a given path in its own zip archive.
# Every zipped file will have a name identical to the path it zipped plus.zip extension. Prompts for a password to encrypt every zip file with
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
  scramble_line "$@" "$password"
}
#######actual script######
function scramfolder_zip_and_move{
    scrambled=$(scram_ext.sh "$1")
    scram_files.sh "$1"
    cd "$scrambled"
    echo "currently in $(pwd)"
    current="$(pwd)"
    parent=$(basename "$current")
    echo parent is $parent
    zip -r -P "$password" "$parent.zip" .
    mv "$parent.zip" $2
    cd ..
}
function loop_scramfolder_zip_and_move {
  cd "$1"
  password="$4"
  for f in */
  do
    scrambled=scramfolder_zip_and_move "$f" "$2" "$password"
    echo "these files exist: $(ls)"
    echo "about to scramble $scrambled"
    scram_files.sh "$scrambled"
    echo "now about to move $f"
    mv "$f" $3
  done
  echo "done with this"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
