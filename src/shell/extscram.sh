#!/bin/bash

#################################################################################################################
# Extension scram. Calls scram.sh only on a filename. Returns the scrambled filename with unscrambled extension #
# When called with the -p option, scrambles the whole file path provided                                        #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                                                     #
#################################################################################################################

function fscramble {
    local xbase="$(basename "$1")" #xbase=${fullname##*/}
    local xfext=$([[ $xbase = *.* ]] && printf %s ".${xbase##*.}" || printf '') #xfext=${xbase##*.} returns filename when no extension.
    local xpref="${xbase%.*}"
    local scrambled="$(echo "$xpref" | scram.sh)"
    printf "$scrambled$xfext\n"
}

function fscramble_whole_path {
    local xfext=$([[ $1 = *.* ]] && printf %s ".${1##*.}" || printf '') #xfext=${xbase##*.} returns filename when no extension.
    local xpref="${1%.*}"
    local scrambled="$(echo "$xpref" | scram.sh)"
    printf "$scrambled$xfext\n"
}

function fscramble_keep_path {
    local xpath="$(dirname "$1")" #xpath=${fullname%/*} not good in edge conditions, gives filename when path is empty
    [[ "$xpath" == "." ]] && xpath="" || xpath="$xpath/"  # avoid prepending a "./" to output
    local xbase="$(basename "$1")" #xbase=${fullname##*/}
    local xfext=$([[ $xbase = *.* ]] && printf %s ".${xbase##*.}" || printf '') #xfext=${xbase##*.} returns filename when no extension.
    local xpref="${xbase%.*}"
    local scrambled="$(echo "$xpref" | scram.sh)"
    extscram_result="$xpath$scrambled$xfext"
    # return the value with a printf. Funcion defined variables are not
    # visible if this script was called from outside
    printf "$extscram_result\n"
}

function _main {
    while getopts ":pk" opt; do
        case $opt in
      p)
          whole_path=true
          shift $((OPTIND-1))
          ;;
      k)
          keep=true
          shift $((OPTIND-1))
          ;;
      \?)
          echo "Invalid option: -$OPTARG" >&2
          ;;
        esac
    done

    if [ -p /dev/stdin ]; then
      while IFS= read name; do
        if [ "$keep" = true ] ; then
           fscramble_keep_path "$name"
        else
          if [ "$whole_path" = true ] ; then
              fscramble_whole_path "$name"
          else
              fscramble "$name"
          fi
        fi
      done
    else
      if [ ! -z "$1" ]; then
        if [ "$keep" = true ] ; then
          fscramble_keep_path "$1"
        else
          if [ "$whole_path" = true ] ; then
              fscramble_whole_path "$1"
          else
              fscramble "$1"
          fi
        fi
      else
        echo "no input given"
      fi
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi
