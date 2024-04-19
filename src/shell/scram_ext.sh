#!/bin/bash

###############################################################################################
# calls scram.sh only on a filename. Returns the scrambled filename with unscrambled extension
###############################################################################################

function fscramble {
    xbase="$(basename "$1")" #xbase=${fullname##*/}
    xfext=$([[ $xbase = *.* ]] && printf %s ".${xbase##*.}" || printf '') #xfext=${xbase##*.} returns filename when no extension.
    xpref="${xbase%.*}"
    scrambled="$(echo "$xpref" | scram.sh)"
    printf "$scrambled$xfext\n"
}

function fscramble_whole_path {
    xbase="$(basename "$1")" #xbase=${fullname##*/}
    xfext=$([[ $1 = *.* ]] && printf %s ".${1##*.}" || printf '') #xfext=${xbase##*.} returns filename when no extension.
    xpref="${1%.*}"
    scrambled="$(echo "$xpref" | scram.sh)"
    printf "$scrambled$xfext\n"
}

while getopts ":p" opt; do
    case $opt in
	p)
	    whole_path=true
	    shift $((OPTIND-1))
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    ;;
    esac
done

if [ -p /dev/stdin ]; then
    while IFS= read name; do
	if [ "$whole_path" = true ] ; then
	    fscramble_whole_path "$name"
	else
	    fscramble "$name"
	fi
    done
else
    if [ ! -z "$1" ]; then
	if [ "$whole_path" = true ] ; then
	    fscramble_whole_path "$1"
	else
	    fscramble "$1"
	fi
    else
	echo "no input given"
    fi
fi
