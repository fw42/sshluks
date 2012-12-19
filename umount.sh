#!/bin/bash
# Unmount a LUKS crypto container

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 1 ]
then
	echo "Usage: $0 <mnt>"
	exit
fi

checkroot

MOUNT_FS="$1"

msg_status "Unmounting filesystem on \"$MOUNT_FS\" (\"$MAPPER/$CRYPTNAME\")..."
umount $MOUNT_FS || die

msg_status "Closing crypto container..."
LOOP=$(cryptsetup status $CRYPTNAME | grep device | awk {'print $2'})
cryptsetup luksClose $CRYPTNAME || die

FILE=$(losetup $LOOP | awk {'print $3'} | sed "s/^(//" | sed "s/)$//")
msg_status "Unmounting container file (\"$FILE\")..."
losetup -d $LOOP
