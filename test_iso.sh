#!/bin/bash

# Tests ISO by running the image in QEMU

if [ $# -eq 0 ]; then
    ISO_TO_USE="bin/$(find bin/ | sort -r | head -n 1)"
else
    ISO_TO_USE="$1"
fi

run_archiso -i "$ISO_TO_USE"
