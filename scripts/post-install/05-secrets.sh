#!/bin/bash
# 
# Copy secret configs (passwords, keys, etc) to their proper locations

# SSH Keys
cp -R /storage/dev/secrets/ssh ~/.ssh

# Sublime-Text License
cp /storage/dev/secrets/sublime-text/License.sublime_license ~/.config/sublime-text-3/Local/

