#!/bin/bash
##
# Enlarge a LUKS crypto container
##

source helper.sh

######

# Path of device mapping which will be used by cryptsetup
MAPPER="/dev/mapper"
CRYPTNAME="container"

# Filesystem tools
RESIZEFS="resize2fs"
FSCK="fsck.ext4"

######

if [ $# -ne 2 ]
then
	echo "Usage: $0 <container> <additional size in MB>"
	exit
fi

checkroot

CONTAINER="$1"
SIZE="$2"
LOOP=$(losetup -f)

msg_status "Enlarging image file \"$CONTAINER\" by $SIZE MiB..."
dd if=/dev/urandom bs=1M count=$SIZE >> $CONTAINER || die

msg_status "Mounting image file \"$CONTAINER\" as \"$LOOP\"..."
losetup $LOOP $CONTAINER || die

msg_status "Mounting crypto container as \"$MAPPER/$CRYPTNAME\"..."
cryptsetup luksOpen $LOOP $CRYPTNAME || die

msg_status "Resizing crypto container..."
cryptsetup resize $CRYPTNAME || die

msg_status "Checking filesystem for errors..."
$FSCK $MAPPER/$CRYPTNAME || die

msg_status "Resizing filesystem ($RESIZEFS)..."
$RESIZEFS $MAPPER/$CRYPTNAME || die

msg_status "Checking filesystem for errors again..."
$FSCK $MAPPER/$CRYPTNAME || die

msg_status "Closing crypto container..."
cryptsetup luksClose $CRYPTNAME || die

msg_status "Unmounting image file..."
losetup -d $LOOP || die

msg_status "Done."
ls -lah $CONTAINER
