#!/bin/bash
#
# Verify mount points needed by other customization scripts

if ! grep -qs '/storage' /proc/mounts; then
    echo "/storage" is not mounted. Aborting.
    exit 1
fi
   
