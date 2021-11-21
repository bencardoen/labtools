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
NOW=$(date +"%m--%d--%Y ~ %I:%M:%S")
echo "Starting processing at $NOW"
case $# in

        3)
        tar --use-compress-program="pigz -p $3 --best --recursive" -c --checkpoint-action=ttyout='%{%Y-%m-%d %H:%M:%S}t (%d sec): #%u, %T%*\r' $1 -f $2
        ;;

        4)
        echo "Excluding $4"
        tar --exclude=$4 --use-compress-program="pigz -p $3 --best --recursive" -c --checkpoint-action=ttyout='%{%Y-%m-%d %H:%M:%S}t (%d sec): #%u, %T%*\r' $1 -f $2
        ;;
        *)
        >&2 echo "Expected usage : $0 SOURCEFOLDER TARGETARCHIVE NUMPROCESSORS <REGEXTOSKIP>(optional)";;
esac
NOW=$(date +"%m--%d--%Y ~ %I:%M:%S")
echo "Completed @ $NOW"
