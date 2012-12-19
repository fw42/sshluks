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
runsshfs $CONTAINER_DIR $MOUNT_SSHFS || die

msg_status "Checking for filesystem lock..."
if [ -e "$MOUNT_SSHFS/lock" ]
then
	die "Filesystem is locked!"
fi

msg_status "Placing filesystem lock..."
echo "$(hostname), $(date)" > $MOUNT_SSHFS/lock

$DIR/mount.sh "$MOUNT_SSHFS/$(basename $CONTAINER)" $MOUNT_FS

msg_status "Done."
df -h $MOUNT_SSHFS $MOUNT_FS
