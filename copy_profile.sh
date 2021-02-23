#!/bin/bash

# Copy the releng profile to create a custom build from the official monthly installation ISO.

mkdir -p build

cp -R /usr/share/archiso/configs/releng/ build

