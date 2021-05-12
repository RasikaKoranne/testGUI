#!/bin/ksh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	ws_sched_600.sh
# Description 		:	Looks for jobs to run and runs them
# Author 		:	WhereScape
# Date			: 	Version 1.0.0  22/01/2002
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# =============================================================================
# Notes / History
#
# version 1.0.7 05/04/2002 Added notification via ws_sched_status_010
# version 1.0.9 22/05/2002 Changed directory to be sub wsl
# version 1.2.1 08/11/2002 Minor fix to ws_sched_check for space recognition
# version 4.1.0 15/08/2003 All variables acquired from the oraenv file
# version 4.1.1 01/03/2005 New calls to Ws_Job_Exec to handle jobs within jobs
# version 5.6.0 18/04/2007 Handle exports
# version 6.0.0 02/07/2008 Db2
# version 6.0.2 02/09/2008 Teradata
# Version 6.7.1 15/04/2012 Teradata UNIX Version
SCHEDULER_VERSION=6000000 # Scheduler version. Do not alter
# ============================================================================
# SETTINGS
# Do not alter SCHED_STATUS_INTERVAL from 600 (ten minutes. If a status update is
# not received after 15 minutes the scheduler is assumed to be down.
SCHED_STATUS_INTERVAL=600 # The time between scheduler status updates(in seconds)
# ============================================================================

TDENV=$HOME/$1
. $TDENV

# Scheduler name. Must be unique and <= 8 characters
if [ "$WSL_SCHEDULER_NAME" = "" ]
then
  SCHEDULER_NAME=UNIX001
else
  SCHEDULER_NAME=$WSL_SCHEDULER_NAME
fi

# Name of the server the scheduler is running on
if [ "$WSL_SCHEDULER_HOST" = "" ]
then
  SCHEDULER_HOST=localhost
else
  SCHEDULER_HOST=$WSL_SCHEDULER_HOST
fi

# The time between checks for jobs (in seconds) (def:30)  
if [ "$WSL_JOB_WAIT_INTERVAL" = "" ]
then
  JOB_WAIT_INTERVAL=30
else
  JOB_WAIT_INTERVAL=$WSL_JOB_WAIT_INTERVAL
fi
      
# The time between checks of running jobs(in seconds) (def:1200)
if [ "$WSL_JOB_CHECK_INTERVAL" = "" ]
then
  JOB_CHECK_INTERVAL=1200
else
  JOB_CHECK_INTERVAL=$WSL_JOB_CHECK_INTERVAL
fi
 
#
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

# Note: acquire the job exe directory from the oraenv file if set.
if [ "$JOB_EXE_DIR" = "" ]
then
  EXE_DIR=$HOME/wsl/sched/job
else
  EXE_DIR=$JOB_EXE_DIR
fi

LOG_FILE=${LOG_DIR}/sched_$1.log
touch $LOG_FILE

JOB_CHECK=$JOB_CHECK_INTERVAL
SCHED_STATUS=$SCHED_STATUS_INTERVAL

while ( true  )
do
   #
   # call job wait. Returns are
   # 0 = job processed,   2 = no jobs,   5 = status requested,   9 = shutdown
   # 23 = bteq non standard return,      24 = bteq failed
   # 25 = ws_job_wait procedure returned a negative status
   # 26 = invalid number of threads. Could mean database is down
   #
   WAITED_FOR=2
   $BIN_DIR/ws_job_wait_600.sh $1 $SCHEDULER_NAME >>$LOG_FILE
   RES=$?
   if [ "$RES" -eq "2" ]
   then
      sleep $JOB_WAIT_INTERVAL
      WAITED_FOR=$JOB_WAIT_INTERVAL
   elif [ "$RES" -eq "5" ]
   then
      SCHED_STATUS=$SCHED_STATUS_INTERVAL
   elif [ "$RES" -eq "9" ]
   then
      date
      echo "Shutdown requested. The Scheduler will terminate.."
      STOP_MSG="Shutdown requested."
      PARAMS="$1 STOP UNIX $SCHEDULER_NAME $SCHEDULER_HOST $JOB_WAIT_INTERVAL $SCHEDULER_VERSION \"$STOP_MSG\""
      $BIN_DIR/ws_sched_status_600.sh $PARAMS
      exit
   elif [ "$RES" -ne "0" ]
   then
      date
      if [ "$RES" -eq "23" ]
      then
         STOP_MSG="bteq had a non standard return code. Check unix logs"
      elif [ "$RES" -eq "24" ]
      then
         STOP_MSG="bteq has failed. Check unix logs"
      elif [ "$RES" -eq "25" ]
      then
         STOP_MSG="Procedure ws_job_wait returned a failure. Check recent audit trail"
      elif [ "$RES" -eq "26" ]
      then
         STOP_MSG="Invalid number of threads. Possibly due to database down"
      else
         STOP_MSG=`echo "ws_job_wait_600.sh $1 returned a status of $RES" | tr " " "^"`
      fi
      echo "ws_job_wait_600.sh $1 $SCHEDULER_NAME returned a status of $RES"
      echo "The Scheduler will terminate.."
      PARAMS="$1 STOP UNIX $SCHEDULER_NAME $SCHEDULER_HOST $JOB_WAIT_INTERVAL $SCHEDULER_VERSION \"$STOP_MSG\""
      $BIN_DIR/ws_sched_status_600.sh $PARAMS
      exit
   fi
 
   let SCHED_STATUS="$SCHED_STATUS+$WAITED_FOR"
   if [ "$SCHED_STATUS" -ge "$SCHED_STATUS_INTERVAL" ]
   then
      PARAMS="$1 STATUS UNIX $SCHEDULER_NAME $SCHEDULER_HOST $JOB_WAIT_INTERVAL $SCHEDULER_VERSION "
      $BIN_DIR/ws_sched_status_600.sh $PARAMS
      SCHED_STATUS=0
   fi

   let JOB_CHECK="$JOB_CHECK+$WAITED_FOR"
   if [ "$JOB_CHECK" -ge "$JOB_CHECK_INTERVAL" ]
   then
      $BIN_DIR/ws_job_check_600.sh $1
      JOB_CHECK=0
   fi
done
exit
