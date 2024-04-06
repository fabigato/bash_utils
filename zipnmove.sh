#!/bin/bash
set -e
#zips every file (not folder) in a given folder in its own zip archive. Every zipped file will have a name identical to the file it contains except for the extension (if present) that will .zip instead. Prompts for a password to encrypt every zip file with
#AUTHOR: Fabián Guevara
#######basic checks#######
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

#######actual script######
cd "$1"
echo "Enter password..."
read -s password
echo "Repeat password..."
read -s password2
if [ "$password" != "$password2" ]
then
	echo "Passwords don't match"
	exit
fi
for f in ./*
do
	if [ -f "$f" ]; then
		echo "processing $f"
		scrambled=$(scram.sh "$f")
		scram_files.sh "$f"
		filename="$(basename "$scrambled")"
		filenamenoext="${filename%.*}"
		zip -P "$password" "$filenamenoext.zip" "$filename"
		mv "$filenamenoext.zip" $2
		scram_files.sh "$scrambled"
		mv "$f" $3
	fi
done
