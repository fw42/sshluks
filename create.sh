#!/bin/bash
# Create a LUKS crypto container with filesystem inside

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 4 ]
then
	echo "Usage: $0 <container> <dd prefix> <dd container> <size>"
	exit
fi

checkroot

CONTAINER="$1"
DD_PREFIX="$2"
DD_CONTAINER="$3"
SIZE="$4"
LOOP=$(losetup -f)

msg_status "Creating image file $CONTAINER of size $SIZE MiB..."
$DD_PREFIX dd if=/dev/urandom of=$DD_CONTAINER bs=1M count=$SIZE || die

msg_status "Mounting image file $CONTAINER as $LOOP..."
losetup $LOOP $CONTAINER || die

msg_status "Creating crypto container inside $CONTAINER ($LUKSFORMAT)..."
cryptsetup $LUKSFORMAT $LOOP || die

msg_status "Mounting crypto container as $CRYPTNAME..."
cryptsetup luksOpen $LOOP $CRYPTNAME || die

msg_status "Creating filesystem ($MKFS) in $MAPPER/$CRYPTNAME..."
mkfs.ext4 $MAPPER/$CRYPTNAME || die

msg_status "Closing crypto container..."
cryptsetup luksClose $CRYPTNAME || die

msg_status "Unmounting image file..."
losetup -d $LOOP || die

msg_status "Done."
ls -lah $CONTAINER
