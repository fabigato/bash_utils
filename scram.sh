#!/bin/bash
if [[ -z "${SCRAM_CHARS}" ]]; then
	echo "You need to provide the scramble chars in the SCRAM_CHARS environment variable"
	exit 1
fi

function scramble_line {
	rev_chars="$(echo "$SCRAM_CHARS" | rev)"
	scrambled="$(echo "$1" | tr "$SCRAM_CHARS" "$rev_chars")"
	printf "$scrambled\n"
}

if [ -p /dev/stdin ]; then
	while IFS= read -r name; do
		scramble_line "$name"
	done
else
	if [ ! -z "$1" ]; then
		scramble_line "$1"
	else
		echo "no input given"
	fi
fi