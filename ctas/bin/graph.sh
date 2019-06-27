#!/bin/bash

[[ $# != 2 ]] && echo "need's 2 args" && exit

START="${1}"
END="${2}"

### assume we give the exact times we want and set 10 min b/f and 10 after
START=$(( START - 600 ))
END=$(( END + 600 ))

mkdir -p "$START-$END"
python ./graph.py $START $END
mv *.png "$START-$END"

exit 0

