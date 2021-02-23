#!/bin/bash

# Edit the profile permissions

sed -i '/file_permissions/a ["/root/install.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/partition.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install/00-verify-mounts.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install/10-home.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install/20-packages.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install/30-aur-packages.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install/40-other-packages.sh"]="0:0:755"' build/releng/profiledef.sh
sed -i '/file_permissions/a ["/root/post-install/50-secrests.sh"]="0:0:755"' build/releng/profiledef.sh

