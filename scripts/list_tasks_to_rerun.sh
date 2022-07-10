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
# Copyright 2022, Ben Cardoen
#!/bin/bash

## Usage ./this.sh JOBID inlist.txt outlist.txt
## Where JOBID is a SLURM array ID, e.g. xyz with xyz_1, xyz_2 etc for sub tasks
## in/out lists are files with input and output for the subtasks
## Example, you have 200 tasks, 12 failed, you need to reschedule the failed ones
## --> run this script and reschedule with the stripped files
set -euo pipefail
ID=$1
IN=$2
OUT=$3
findfailed () { sacct -X -j $1 -o JobID,State,ExitCode,DerivedExitCode | grep -v COMPLETED ; }
findfailed $ID > failed.txt
FN=`wc -l failed.txt | awk '{print $1}'`
N=$(($FN - 2))
echo "Found $N failed array job ids, recreating sub lists for reprocessing"
tail -$N failed.txt | awk '{print $1}' | cut -d_ -f 2 > lines.txt
echo "Writing new lists"
sed 's/^/NR==/' lines.txt | awk -f - $IN > inlist_rerun.txt
sed 's/^/NR==/' lines.txt | awk -f - $OUT  > outlist_rerun.txt
echo "Done"
