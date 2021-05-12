#!/bin/ksh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	ws_job_check_600.sh
# Description 		:	Checks that running jobs are actually active
# Author 		:	WhereScape Limited
# Date			: 	Version 1.0.0  07/01/2002
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# =============================================================================
# Notes / History
#
# WMR 04/10/2002 fixed jobs with spaces in name tr " " "_" in JOBSEQ
# WMR 07/04/2003 abort of jobs with spaces fixed. Spaces no longer removed
# WMR 28/11/2003 look for WSLnnnn_ where nnnn is the sequence instead of name
# WMR 01/03/2005 handle new jobs within jobs
# WMR 30/07/2008 Handle DB2 trusted connections
# JML 02/09/2008 Teradata
# AP  06/05/2009 Corrected reference to 411 to 600 for ws_jobs_600_
# RS  26/07/2012 Added ".exit" to bteq calls
# RS  27/07/2012 Added capture of bteq warnings and errors into log-file
# JML 14/12/2012 RED_2949 correctly parse SEQ variable  
# JML 15/04/2012 Teradata UNIX Version
# ============================================================================
# SETTINGS
#
TDENV=$HOME/$1
RUNSHELL=ksh
# ============================================================================
. $TDENV

# Note: acquire the bin directory from the tdenv file if set.
if [ "$WSL_BIN_DIR" = "" ]
then
  BIN_DIR=$HOME/wsl/bin
else
  BIN_DIR=$WSL_BIN_DIR
fi
# Note: acquire the log directory from the tdenv file if set.
if [ "$WSL_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/sched/log
else
  LOG_DIR=$WSL_LOG_DIR
fi

CHECK_FILE=${LOG_DIR}/job_check_$1_`date +%Y%m%d`.log
##
# Issue a sql command to get the jobs to check
##

RES1=`bteq <<EOF2 2>&1
.logon ${DSS_BTEQDB}/${DSS_USER},${DSS_PWD}
.set width 254
.set foldline on 1,2,3,4,5
CALL $DSS_METABASE.ws_job_check(?,?,?,?,?);
.exit
EOF2`
RES2=$?

##
# Check for  warning text as bteq exits with 0
##

BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`

if [ "$RES2" -ne "0" -o "$BTEQ_WARNING" != "" ]
then
  if [ "$RES2" -eq "4" -o "$BTEQ_WARNING" != "" ]
  then
    echo "Failure when issuing the ws_job_check procedure. Bteq issued a warning"
  else
    echo "Failure when issuing the Ws_Job_check procedure. Return code from bteq of $RES2"
  fi
  echo "$RES1"
  exit
fi
#
# See if we have any jobs to check. If none then exit
#
LINE=`echo "$RES1" | grep -n "p_job_count" | cut -d: -f1`
let LINE="$LINE+14"
JOB_COUNT=`echo "$RES1" | head -$LINE | tail -5 | head -1 | tr -d ' '`
if [ "$JOB_COUNT" -eq "0" ]
then
  exit
fi
#
# get a list of the processes on the machine
if [ "$RUNSHELL" = "ksh" ]
then
  ps -ef >/tmp/ws_jobs_600_$1.txt
else
  ps -efw >/tmp/ws_jobs_600_$1.txt
fi

nJob=0
JOBSEQ=`echo "$RES1" | head -$LINE | tail -3 | head -1 | tr -d ' '`
for JOBS in $JOBSEQ 
do
  let nJob="$nJob+1"
  JOB=`echo "$RES1" | head -$LINE | tail -2 | head -1 | cut -d "," -f$nJob`
  SEQ=`echo "$RES1" | head -$LINE | tail -1 | head -1 | tr -d ' ' | cut -d "," -f$nJob`
  CNT=`cat /tmp/ws_jobs_600_$1.txt | grep WSL$SEQ | wc -l`
 
  if [ "$CNT" -lt "1" ]
  then
    echo "No active job found. Aborting job $JOBS at `date`" >>$CHECK_FILE
    echo "No active job found. Aborting job $JOB sequence $SEQ at `date`" >>$CHECK_FILE
    RES3=`bteq <<EOF4 2>&1
    .logon ${DSS_BTEQDB}/${DSS_USER},${DSS_PWD}
    CALL $DSS_METABASE.ws_job_abort('$JOB',$SEQ,'No active job found under Unix');
    .exit
EOF4`
    RES2=$?

    if [ "$RES2" -ne "0" -o "$BTEQ_WARNING" != "" ]
    then
      if [ "$RES2" -eq "4" -o "$BTEQ_WARNING" != "" ]
      then
    	echo "Failure when issuing the ws_job_abort procedure. Bteq issued a warning"
      else
    	echo "Failure when issuing the ws_job_abort procedure. Return code from bteq of $RES2"
      fi
      echo "$RES3"
      exit
    fi

  fi
done
exit
