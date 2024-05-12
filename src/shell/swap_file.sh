#!/bin/bash

##############################################################################
# Applies scram to the whole content of a given text file.                   #
# Provide the text file through either command line or the SWAP_FILE env var #
# Author: ricardo.fabian.guevara@gmail.com (Fabián Guevara)                  #
##############################################################################

if [ ! -z "$1" ]; then
	file="$1"
else
	if [ ! -z "$SWAP_FILE" ]; then
		file="$SWAP_FILE"
	else
		echo either provide a file name or set the SWAP_FILE env variable
		exit 1
	fi
fi
readarray -t lines < "$file"  # read whole file in memory, otherwise you can´t update line by line while reading
swapped_lines=()
for line in "${lines[@]}"; do
    swapped_lines+=( "$(echo "$line" | scram.sh)" )
done
printf '%s\n' "${swapped_lines[@]}" >"$file"