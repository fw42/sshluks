#!/bin/bash
# Mount an sshfs directory

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 2 ]
then
	echo "Usage: $0 <remote-dir> <local-mnt>"
	exit
fi

checkroot

REMOTE="$1"
MOUNT_SSHFS="$2"

msg_status "Mounting \"$REMOTE\" on \"$MOUNT_SSHFS\"..."
runsshfs $REMOTE $MOUNT_SSHFS || die

msg_status "Done."
df -h $MOUNT_SSHFS
