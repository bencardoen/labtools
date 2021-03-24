#!/bin/bash
set -euo pipefail
if (( $# != 3 )); then
    >&2 echo "Expected usage : $./compress.sh SOURCEFOLDER TARGETARCHIVE NUMPROCESSORS"
fi
SOURCE=$1 # First argument is source directory (/home/important/stuff/)
TARGET=$2 # Second argument is the archive ('mystuf.tar.gz')
PROCESSORS=$3 # Nr of processors to use (4-8 is the sweet spot)
echo "Archiving $SOURCE into $TARGET using $PROCESSORS parallel processes"
tar cf - $SOURCE  -P | pv -s $(du -sb $SOURCE | awk '{print $1}') | pigz -p $PROCESSORS > $TARGET
