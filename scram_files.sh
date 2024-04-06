if [ -z "$1" ]
then
    echo "No arguments supplied"
    exit
fi
fullname="$1"
echo "$fullname"
function fscramble { #takes a string and scrambles it according to a fixed mapping
    xpath="$(dirname "$1")" #xpath=${fullname%/*} not good in edge conditions, gives filename when path is empty
    xbase="$(basename "$1")" #xbase=${fullname##*/}
    xfext=$([[ $xbase = *.* ]] && printf %s ".${xbase##*.}" || printf '') #xfext=${xbase##*.} returns filename when no extension.
    xpref="${xbase%.*}"
    scrambled="$(echo "$xpref" | scram.sh)"
    mv "$1" "$xpath/$scrambled$xfext"
}
if [ -f "$fullname" ] #if argument is a file, scramble its name
then
    fscramble "$fullname"
else #if argument is a folder, scramble recursively inside it
    find "$fullname" -depth | while read f #didn't work with for f in "$(find "$fullname" -depth)
    do
	fscramble "$f"
    done
fi

