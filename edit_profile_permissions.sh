#!/bin/bash

# Edit the profile permissions

sed -i '/file_permissions/a ["/root/install.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/customize.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install.sh"]="0:0:755"' build/releng/profiledef.sh

# Use custom build of mkarchiso via dev/gitlab/archiso
# to allow recursive setting of permissions in a folder.
# Fix in mkarchiso scheduled for release 52 of archiso.
sed -i '/file_permissions/a ["/root/post-install"]="1000:1000:770"' build/releng/profiledef.sh

