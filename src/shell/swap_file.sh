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
# next line doesn't work in Mac due to outdated bash version which doesn't include read array
# readarray -t lines < "$file"  # read whole file in memory, otherwise you can´t update line by line while reading
IFS=
while read line; do
    lines+=($line)
done < "$file"
swapped_lines=()
for line in "${lines[@]}"; do
    swapped_lines+=( "$(echo "$line" | scram.sh)" )
done
printf '%s\n' "${swapped_lines[@]}" >"$file"