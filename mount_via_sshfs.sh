#!/bin/bash
# Mount a LUKS crypto container from SSHFS

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 4 ] || [[ "$4" != "ro" && "$4" != "rw" ]]
then
	echo "Usage: $0 <container-remote> <mnt-sshfs> <mnt-fs> <ro/rw>"
	exit
fi

checkroot

CONTAINER="$1"
MOUNT_SSHFS="$2"
MOUNT_FS="$3"
RORW="$4"
LOOP=$(losetup -f)

CONTAINER_DIR=$(dirname $CONTAINER)
msg_status "Mounting \"$CONTAINER_DIR\" on \"$MOUNT_SSHFS\"..."
runuser $SSHFS $CONTAINER_DIR $MOUNT_SSHFS || die

msg_status "Checking for filesystem lock..."
if [ -e "$MOUNT_SSHFS/lock" ]
then
	die "Filesystem is locked!"
fi

msg_status "Placing filesystem lock..."
echo "$(hostname), $(date)" > $MOUNT_SSHFS/lock

$DIR/mount.sh "$MOUNT_SSHFS/$(basename $CONTAINER)" $MOUNT_FS $RORW

msg_status "Done."
df -h $MOUNT_SSHFS $MOUNT_FS
