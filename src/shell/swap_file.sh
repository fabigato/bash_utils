#!/bin/bash
if [ ! -z "$1" ]; then
	file="$1"
else
	if [ ! -z "$PORT_INDEX" ]; then
		file="$PORT_INDEX"
	else
		echo either provide a file name or set the PORT_INDEX env variable
		exit 1
	fi
fi
readarray -t lines < "$file"  # read whole file in memory, otherwise you can´t update line by line while reading
swapped_lines=()
for line in "${lines[@]}"; do
    swapped_lines+=( "$(echo "$line" | scram.sh)" )
done
printf '%s\n' "${swapped_lines[@]}" >"$file"