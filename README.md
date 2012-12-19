sshluks
=======

Small collection of shell scripts used for creating, enlarging, shrinking, mounting,
and unmounting of crypto containers on sshfs remote storage.

Tools used: cryptsetup/LUKS for encryption, losetup for device mapping, sshfs for network access.

Important: `mount_via_ssh.sh` implements locking, such that no two clients will ever access the container
file at the same time. Ignoring those locks can result in serious damage to the filesystem inside the container!

Getting started
---------------

* Have a look at config.sh

* Create directory for storing the container file on the remote host

    $ ssh server mkdir -p /srv/backup/flo/foobar/

* Mount remote directory via sshfs

    $ sudo ./sshfs.sh server:/srv/backup/flo/foobar/ ~/mnt/server

* Create container file with LUKS and filesystem inside

    $ sudo ./create.sh ~/mnt/server/container_file "ssh server" "/srv/backup/flo/foobar/container_file" 1024

* Unmount sshfs

    $ sudo umount ~/mnt/server

* Mount the filesystem inside the container for use

    $ sudo ./mount_via_sshfs.sh server:/srv/backup/flo/foobar/container_file ~/mnt/server ~/mnt/server_container

* Perform your backup or whatever

* Unmount the filesystem when you are done

    $ sudo ~/sshluks/umount.sh ~/mnt/server_container

More advanced stuff
-------------------

* Enlarge container file

    $ sudo ./enlarge.sh ~/mnt/server/container_file "ssh server" "/srv/backup/flo/foobar/container_file" 100

* Shrinking container file
 * Does not work yet, but should be possible :-(
