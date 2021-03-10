#!/bin/bash

# Edit the profile permissions

sed -i '/file_permissions/a ["/root/install.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/partition.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install.sh"]="0:0:755"' build/releng/profiledef.sh

# Use custom build of mkarchiso via dev/gitlab/archiso
# to allow recursive setting of permissions in a folder
sed -i '/file_permissions/a ["/root/post-install"]="1000:1000:770"' build/releng/profiledef.sh

