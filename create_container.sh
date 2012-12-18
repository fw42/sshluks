#!/bin/bash
# Create a LUKS crypto container with filesystem inside
source helper.sh

######

# Path of device mapping which will be used by cryptsetup
MAPPER="/dev/mapper"
CRYPTNAME="container"

# Options for cryptsetup luksFormat
OPTIONS="-c aes-cbc-essiv:sha256"

# Command for creating the filesystem inside the container
MKFS="mkfs.ext4"

######

if [ $# -ne 2 ]
then
	echo "Usage: $0 <container> <size in MB>"
	exit
fi

checkroot

CONTAINER="$1"
SIZE="$2"
LOOP=$(losetup -f)

msg_status "Creating image file $CONTAINER of size $SIZE MiB..."
dd if=/dev/zero of=$CONTAINER bs=1M count=$SIZE || die

msg_status "Mounting image file $CONTAINER as $LOOP..."
losetup $LOOP $CONTAINER || die

msg_status "Creating crypto container inside $CONTAINER ($OPTIONS)..."
cryptsetup $OPTIONS luksFormat $LOOP || die

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
