#!/bin/sh
# Given $JOBID, inlist, outist of a batch job, find the failed entries of the array, selects those from the array files, and makes new ones so you can reschedule
# AGPLv3, author Ben Cardoen
# Usage ./this.sh $JOBID infiles.txt outfiles.txt
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
