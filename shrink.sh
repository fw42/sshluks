#!/bin/bash
# Shrink a LUKS crypto container

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 2 ]
then
	echo "Usage: $0 <container> <new size in MB>"
	exit
fi

echo WARNING - WIP - NOT CORRECT RIGHT NOW!
exit

checkroot

CONTAINER="$1"
SIZE="$2"
LOOP=$(losetup -f)

msg_status "Mounting image file \"$CONTAINER\" as \"$LOOP\"..."
losetup $LOOP $CONTAINER || die

msg_status "Mounting crypto container as \"$MAPPER/$CRYPTNAME\"..."
cryptsetup luksOpen $LOOP $CRYPTNAME || die

msg_status "Checking filesystem for errors..."
$FSCK_FORCE $MAPPER/$CRYPTNAME || die

msg_status "Resizing filesystem ($RESIZEFS)..."
$RESIZEFS $MAPPER/$CRYPTNAME "${SIZE}M" || die

msg_status "Checking filesystem for errors again..."
$FSCK_FORCE $MAPPER/$CRYPTNAME || die

# Probably wrong!
msg_status "Resizing crypto container..."
cryptsetup resize $CRYPTNAME --size $(expr 2 \* $SIZE) || die

msg_status "Closing crypto container..."
cryptsetup luksClose $CRYPTNAME || die

# Most certainly wrong!
msg_status "Truncating image file \"$CONTAINER\" to new total size of $SIZE MiB..."
truncate -s "${SIZE}M" $CONTAINER || die

msg_status "Unmounting image file..."
losetup -d $LOOP || die

msg_status "Done."
ls -lah $CONTAINER
