#!/bin/ksh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	ws_job_check_411.sh
# Description 		:	Checks that running jobs are actually active
# Author 		:	WhereScape Limited
# Date			: 	Version 1.0.0  07/01/2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# WMR 04/10/2002 fixed jobs with spaces in name tr " " "_" in JOBSEQ
# WMR 07/04/2003 abort of jobs with spaces fixed. Spaces no longer removed
# WMR 28/11/2003 look for WSLnnnn_ where nnnn is the sequence instead of name
# WMR 01/03/2005 Handle jobs within jobs (4.1.1.3)
# ============================================================================
# SETTINGS
#
ORAENV=$HOME/$1
RUNSHELL=ksh
# ============================================================================
. $ORAENV

# Note: acquire the bin directory from the oraenv file if set.
if [ "$WSL_BIN_DIR" = "" ]
then
  BIN_DIR=$HOME/wsl/bin
else
  BIN_DIR=$WSL_BIN_DIR
fi
# Note: acquire the log directory from the oraenv file if set.
if [ "$WSL_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/sched/log
else
  LOG_DIR=$WSL_LOG_DIR
fi

CHECK_FILE=${LOG_DIR}/job_check_$1_`date +%Y%m%d`.log
##
# Issue a sqlplus command to get the jobs to check
##

sqlplus -s <<EOF| grep -v "completed" | grep -v "^$" >/tmp/ws_job_check_411_$1.txt
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
variable x number;
variable job_count number;
variable pend_count number;
variable jobseq varchar2(4000);
variable job varchar2(4000);
variable seq varchar2(4000);
exec :x := ws_job_check(:job_count, :pend_count, :jobseq, :job, :seq);
print :x :job_count :pend_count :jobseq :job :seq
exit;
EOF

##
# Check that the sqlplus command worked.
# Often when sqlplus fails with an Oracle error it will echo
# the start of the command so we will see BEGIN... returned
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$CHECK_FILE
   echo "check the file /tmp/ws_job_check_411_$1.txt" >>$CHECK_FILE
   exit
fi
RET_CHECK=`echo $RES | cut -d " " -f1`
if [ "$RET_CHECK" = "BEGIN" ]
then
   echo "Sqlplus failed with an oracle error. See logs" >>$CHECK_FILE
   echo "check the file /tmp/ws_job_check_411_$1.txt" >>$CHECK_FILE
   exit -1
fi
#
# See if we have any jobs to check. If none then exit
#
JOB_COUNT=`head -2 /tmp/ws_job_check_411_$1.txt |tail -1 | tr -d " "`
if [ "$JOB_COUNT" -eq "0" ]
then
   exit
fi

#
# get a list of the processes on the machine
if [ "$RUNSHELL" = "ksh" ]
then
   ps -ef >/tmp/ws_jobs_411_$1.txt
else
   ps -efw >/tmp/ws_jobs_411_$1.txt
fi

nJob=0
JOBSEQ=WSL`head -6 /tmp/ws_job_check_411_$1.txt | tail -1 | tr " " "_" | tr "," " "`_
for JOBS in $JOBSEQ 
do
    let nJob="$nJob+1"
    CNT=`cat /tmp/ws_jobs_411_$1.txt | grep $JOBS | wc -l`
 
    if [ "$CNT" -lt "1" ]
    then
       echo "No active job found. Aborting job $JOBS at `date`" >>$CHECK_FILE
       JOB=`head -5 /tmp/ws_job_check_411_$1.txt | tail -1 | cut -d "," -f$nJob`
       SEQ=`head -6 /tmp/ws_job_check_411_$1.txt | tail -1 | tr -d " " | cut -d "," -f$nJob`
       echo "No active job found. Aborting job $JOB sequence $SEQ at `date`" >>$CHECK_FILE
       sqlplus -s <<EOF1
       $DSS_USER/$DSS_PWD
       variable x number;
       exec :x := ws_job_abort('$JOB',$SEQ,'No active job found under Unix');
       exit;
EOF1

    fi
done
exit
