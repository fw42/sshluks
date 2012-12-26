#!/bin/sh

# Name of local system user (used for sshfs UID stuff and ssh commands)
LOCALUSER="flo"

# Path of device mapping which will be used by cryptsetup
MAPPER="/dev/mapper"
CRYPTNAME="sshluks_container"

# Options for cryptsetup luksFormat
LUKSFORMAT="-c aes-cbc-essiv:sha256 luksFormat"

# Filesystem stuff
MKFS="mkfs.ext4 -m 0"
RESIZEFS="resize2fs -p"
FSCK="fsck.ext4"
FSCK_FORCE="$FSCK -f"
MOUNT="mount -t ext4 -o noatime,nodiratime,noacl,commit=1,errors=remount-ro"

# SSHFS options
SSHFS="sshfs -o uid=$(id -u $LOCALUSER),reconnect,allow_root"

# Device used for creating containers. Use /dev/urandom if you are paranoid (and patient).
FILLDEV=/dev/zero
