#!/bin/bash
#@author Ben Cardoen
#Remote mounts Cedar home drive
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.

#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

## For OS detection part
## Source: https://stackoverflow.com/questions/3466166/how-to-check-if-running-in-cygwin-mac-or-linux

UNMOUNT=false
CACHE=300
case $# in
	1)
			MOUNTPOINT=$1
			echo "Unmounting $1"
			UNMOUNT=true
			;;
  2)
			REMOTE=$1
			MOUNTPOINT=$2
  		;;
	3)
			REMOTE=$1
			MOUNTPOINT=$2
			CACHE=$3
			;;
  *)
        >&2 echo "Expected usage : $0 REMOTE MOUNTPOINT  [CACHETIMEOUT=300] , e.g. $0 server.com:/home/me /mnt/remote, or $0 server.com:/home/me /mnt/remote 0,  or $0 /mnt/remote to unmount. Cachetimeout in seconds."
	;;
esac
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
			machine=Linux
			UMOUNTCMD="fusermount3 -u $MOUNTPOINT";;
    Darwin*)
			machine=Mac
			UMOUNTCMD="umount $MOUNTPOINT";;
    CYGWIN*)
			machine=Cygwin;;
    MINGW*)
			machine=MinGw;;
    *)
			echo "Unsupported ENV ${unameOut}" && exit -1;
esac

# UMOUNTCMD="fusermount3 -u $MOUNTPOINT"

if [ "$UNMOUNT" = true ]
then
	echo "Trying to unmount $MOUNTPOINT ..."
	$UMOUNTCMD
	echo "...done"
	exit $?
fi

OPTIONS="-C -o follow_symlinks -o cache=yes -o reconnect -o cache_timeout=$CACHE -o kernel_cache"

if [[ ! -d "$MOUNTPOINT" ]]
then
    echo "$MOUNTPOINT does exist on your filesystem, creating"
    mkdir -p $MOUNTPOINT
    if [ $? -ne 0 ]; then
    	echo "Failed creating $MOUNTPOINT, giving up"
			exit -1
    fi
    echo "Succesfully created $MOUNTPOINT"
fi


echo "Mounting remote file systems @ $REMOTE to $MOUNTPOINT ... with options $OPTIONS"
sshfs $REMOTE $MOUNTPOINT $OPTIONS
if [ $? -eq 0 ]; then
	echo "Mount succesfull"
else
	echo "Mount failed"
	echo "Trying umount to resolve old mounts ..."
	$UMOUNTCMD
	if [ $? -eq 0 ]; then
		echo "Force unmount successful, trying to mount again ..."
		sshfs $REMOTE $MOUNTPOINT $OPTIONS
		if [ $? -eq 0 ]; then
			echo "... Mount successful"
		else
			echo "... Failed, giving up...."
		fi
	else
		echo "... Force unmount failed, giving up"
	fi
fi
echo "Done"
