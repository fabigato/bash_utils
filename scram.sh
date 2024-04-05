#!/bin/bash
if [[ -z "${SCRAM_CHARS}" ]]; then
	echo "You need to provide the scramble chars in the SCRAM_CHARS environment variable"
	exit 1
fi
rev_chars="$(echo "$SCRAM_CHARS" | rev)"
scrambled="$(echo "$1" | tr "$SCRAM_CHARS" "$rev_chars")"
printf "$scrambled\n"