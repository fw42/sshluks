#!/bin/bash
# Mount a LUKS crypto container from SSHFS

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 3 ]
then
	echo "Usage: $0 <container-remote> <mnt-sshfs> <mnt-fs>"
	exit
fi

checkroot

CONTAINER="$1"
MOUNT_SSHFS="$2"
MOUNT_FS="$3"
LOOP=$(losetup -f)

CONTAINER_DIR=$(dirname $CONTAINER)
msg_status "Mounting \"$CONTAINER_DIR\" on \"$MOUNT_SSHFS\"..."
echo $SSHFS $CONTAINER_DIR $MOUNT_SSHFS
runsshfs $CONTAINER_DIR $MOUNT_SSHFS || die
SSHFS_PID=$!

msg_status "Checking for filesystem lock..."
if [ -e "$MOUNT_SSHFS/lock" ]
then
	umount $MOUNT_SSHFS
	die "Filesystem is locked!"
fi

msg_status "Placing filesystem lock..."
echo "$(date), $(hostname), $SSHFS_PID" > $MOUNT_SSHFS/lock

CONTAINER_LOCAL="$MOUNT_SSHFS/$(basename $CONTAINER)"
msg_status "Mounting image file \"$CONTAINER_LOCAL\" as $LOOP..."
losetup $LOOP $CONTAINER_LOCAL || die

msg_status "Mounting crypto container as $CRYPTNAME..."
cryptsetup luksOpen $LOOP $CRYPTNAME || die

msg_status "Checking filesystem for errors..."
$FSCK $MAPPER/$CRYPTNAME || die

msg_status "Mounting filesystem as $MOUNT_FS..."
$MOUNT $MAPPER/$CRYPTNAME $MOUNT_FS || die

msg_status "Done."
df -h $MOUNT_SSHFS $MOUNT_FS
