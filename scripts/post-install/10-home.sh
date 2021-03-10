#!/bin/bash
# 
# Configure home directory

# Setup symlinks
ln -s /storage/dev ~/dev
ln -s /storage/documents ~/documents
ln -s /storage/music ~/music
ln -s /storage/videos ~/videos

# Setup dotfiles
pushd /storage/dev/github || exit
if [ ! -d "/storage/dev/github/dotfiles" ]; then
    git clone git@github.com:michaelgilch/dotfiles.git
fi
pushd dotfiles || exit
/bin/bash setup.sh
popd || exit; popd || exit


