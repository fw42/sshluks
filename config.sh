#!/bin/sh

# Path of device mapping which will be used by cryptsetup
MAPPER="/dev/mapper"
CRYPTNAME="container"

# Options for cryptsetup luksFormat
LUKSFORMAT="-c aes-cbc-essiv:sha256 luksFormat"

# Filesystem stuff
MKFS="mkfs.ext4 -m 0"
RESIZEFS="resize2fs -p"
FSCK="fsck.ext4 -f"
MOUNT="mount -t ext4 -o noatime,nodiratime,noacl,commit=1,errors=remount-ro"

# SSHFS options
LOCALUSER="flo"
runsshfs(){
	su $LOCALUSER -c "sshfs -o uid=$(id -u $LOCALUSER),reconnect,allow_root $*"
}
