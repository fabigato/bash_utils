#!/bin/bash

##################################################################################################
# Replaces the characters in a given string in a reversible fashion according to a given mapping.#
# Provide the chars to be replaced. The nth character will be swapped with the len - n one,      #
# where n is the number of characters provided.                                                  #
# Provide the characters as a command argument or through the SCRAM_CHARS env var                #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                                      #
##################################################################################################


function scramble_line {
	rev_chars="$(echo "$2" | rev)"
	scrambled="$(echo "$1" | tr "$2" "$rev_chars")"
	printf "$scrambled\n"
}

function _main {
    if [[ -z "${SCRAM_CHARS}" ]]; then
      echo "You need to provide the scramble chars in the SCRAM_CHARS environment variable"
      exit 1
    fi
    if [ -p /dev/stdin ]; then
      while IFS= read -r name; do
        scramble_line "$name" "$SCRAM_CHARS"
      done
    else
      if [ ! -z "$1" ]; then
        scramble_line "$1" "$SCRAM_CHARS"
      else
        echo "no input given"
      fi
    fi
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi