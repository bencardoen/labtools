# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# Copyright 2021, Ben Cardoen
#!/bin/bash
set -euo pipefail
if (( $# != 4 )); then
    >&2 echo "Expected usage : $./compress.sh SOURCEFOLDER TARGETARCHIVE NUMPROCESSORS REGEXTOSKIP"
fi
INDIR=$1
ARCHIVE=$2
CORES=$3
EXCLUDEREGEX=$4

tar --exclude=${EXCLUDEREGEX} --use-compress-program="pigz -p $CORES --best --recursive" -c --checkpoint-action=ttyout='%{%Y-%m-%d %H:%M:%S}t (%d sec): #%u, %T%*\r' $INDIR -f $ARCHIVE 
