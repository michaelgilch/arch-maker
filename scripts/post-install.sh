#!/bin/bash
#
# Finish installing Arch Linux via customization scripts

function run_script() {
    /bin/bash post-install/"$1"
    if [ $? -ne 0 ]; then
        echo "Ran into some problems with "$1". Exiting."
        exit 1
    fi
}

for f in [0-9][0-9]-*.sh
do
    if [ $1 == 'test' ]; then
        echo "$f"
    else
        run_script "$f"
    fi
done


