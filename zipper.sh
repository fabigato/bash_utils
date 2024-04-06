#!/bin/bash
#zips every file (not folder) in a given folder in its own zip archive. Every zipped file will have a name identical to the file it contains except for the extension (if present) that will .zip instead. Prompts for a password to encrypt every zip file with
#AUTHOR: Fabián Guevara
#######basic checks#######
if [ -z "$1" ]
	then
		echo "No arguments supplied"
		echo "Usage:"
		echo "zipper.sh FOLDER"
		exit
fi
if [ ! -d "$1" ]
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
	filename="$(basename "$f")"
	filenamenoext="${filename%.*}"
	#echo "processing $f..."
	echo "processing $filenamenoext..."
	zip -P "$password" "$filenamenoext.zip" "$filename"
done
