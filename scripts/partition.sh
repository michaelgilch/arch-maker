#!/bin/bash
#
# Pre-install script to configure partitions
#
# Currently setup for just DaVinci PC

mkfs.ext4 /dev/{sdd1,sdd2,sdd3}
mkdir {/mnt/var,/mnt/home}
mount /dev/{sdd1,sdd2,sdd3} {/mnt,/mnt/var,/mnt/home}

mount /dev/sd{a1,b1,c1} {/storage,/vms,/backup}
