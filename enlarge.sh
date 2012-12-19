#!/bin/bash
# Enlarge a LUKS crypto container

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 4 ]
then
	echo "Usage: $0 <container> <dd prefix> <dd container> <additional size in MB>"
	exit
fi

checkroot

CONTAINER="$1"
DD_PREFIX="$2"
DD_CONTAINER="$3"
SIZE="$4"
LOOP=$(losetup -f)

msg_status "Enlarging image file \"$DD_CONTAINER\" by $SIZE MiB... (using $DD_PREFIX)"
runuser $DD_PREFIX dd if=$FILLDEV bs=1M count=$SIZE of=$DD_CONTAINER oflag=append conv=notrunc || die

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
