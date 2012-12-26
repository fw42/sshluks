#!/bin/bash
# Mount a LUKS crypto container

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 3 ] || [[ "$3" != "ro" && "$3" != "rw" ]]
then
	echo "Usage: $0 <container> <mnt> <ro/rw>"
	exit
fi

checkroot

CONTAINER="$1"
MOUNT_FS="$2"
RORW="$3"
LOOP=$(losetup -f)

msg_status "Mounting image file \"$CONTAINER\" as \"$LOOP\"..."
losetup $LOOP $CONTAINER || die

msg_status "Mounting crypto container as \"$CRYPTNAME\"..."
cryptsetup luksOpen $LOOP $CRYPTNAME || die

msg_status "Checking filesystem for errors..."
$FSCK $MAPPER/$CRYPTNAME || die

msg_status "Mounting filesystem as \"$MOUNT_FS\" ($RORW)..."
$MOUNT -o $RORW $MAPPER/$CRYPTNAME $MOUNT_FS || die
