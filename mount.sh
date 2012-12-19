#!/bin/bash
# Mount a LUKS crypto container

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 2 ]
then
	echo "Usage: $0 <container> <mnt>"
	exit
fi

checkroot

CONTAINER="$1"
MOUNT_FS="$2"
LOOP=$(losetup -f)

msg_status "Mounting image file \"$CONTAINER\" as \"$LOOP\"..."
losetup $LOOP $CONTAINER || die

msg_status "Mounting crypto container as \"$CRYPTNAME\"..."
cryptsetup luksOpen $LOOP $CRYPTNAME || die

msg_status "Checking filesystem for errors..."
$FSCK $MAPPER/$CRYPTNAME || die

msg_status "Mounting filesystem as \"$MOUNT_FS\"..."
$MOUNT $MAPPER/$CRYPTNAME $MOUNT_FS || die
