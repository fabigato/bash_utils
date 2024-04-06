#!/bin/bash
file="/media/data_ext4/Dropbox/misc/misc/iubosu_gnd x.txt"
# cat "$file" | ./scram.sh # > "$file"
readarray -t lines < "$file"
swapped_lines=()
for line in "${lines[@]}"; do
    swapped_lines+=( "$(echo "$line" | ./scram.sh)" )
done
printf '%s\n' "${swapped_lines[@]}" >"$file"