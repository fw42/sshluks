#!/bin/bash
# Unmount a LUKS crypto container

DIR=$(dirname $0)
source $DIR/helper.sh
source $DIR/config.sh

if [ $# -ne 1 ]
then
	echo "Usage: $0 <mnt>"
	exit
fi

checkroot

MOUNT_FS="$1"

msg_status "Unmounting filesystem on \"$MOUNT_FS\" (\"$MAPPER/$CRYPTNAME\")..."
sync
umount $MOUNT_FS || die

msg_status "Closing crypto container..."
LOOP=$(cryptsetup status $CRYPTNAME | grep device | awk {'print $2'})
cryptsetup luksClose $CRYPTNAME || die

FILE=$(losetup $LOOP | awk {'print $3'} | sed "s/^(//" | sed "s/)$//")
msg_status "Unmounting container file (\"$FILE\")..."
losetup -d $LOOP || die

MOUNT_SSHFS=$(stat -c "%m" $FILE)
if [ "$(findmnt $MOUNT_SSHFS -n -o FSTYPE)" == "fuse.sshfs" ]
then
	msg_status "Removing filesystem lock..."
	rm -f $(dirname $FILE)/lock

	msg_status "Unmounting sshfs (\"$MOUNT_SSHFS\")..."
	sync
	umount $MOUNT_SSHFS || die
fi

msg_status "Done."
