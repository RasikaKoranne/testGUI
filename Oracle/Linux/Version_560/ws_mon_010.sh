#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 	:	ws_mon_010.sh
# Description 	:	Monitor database and jobs. Notify if required
# Author 		:	Wayne Richmond
# Date			: 	Version 1.0.0  03/10/2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# WMR  15/08/2003   Version 4.1 Put variables back into oraenv
#
MON_VER=4001001           # Monitor script version
# ============================================================================
# SETTINGS
#
BACK_HOURS=2              # How far to look back for problems. (see documentation)
BACK_MIN=0                # How far to look back for problems. (see documentation)
LOG_LEVEL=2               # Level 2 = notifications only, 3 = notify + notify skipped
                          # 5 = main events 9 = debug
JOB_POLL_MIN=15           # The time between job checks in minutes
DB_POLL_MIN=60            # The time between database checks in minutes

MON_HOST=localhost        # Name of the server the monitor is running on
#
# ============================================================================

LAST_DAY_NO=0

# Note: acquire the bin directory from the oraenv file if set.
if [ "$WSL_BIN_DIR" = "" ]
then
  BIN_DIR=$HOME/wsl/bin
else
  BIN_DIR=$WSL_BIN_DIR
fi

# Note: acquire the mon log directory from the oraenv file if set.
if [ "$MON_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/mon/log
else
  LOG_DIR=$MON_LOG_DIR
fi

# Note: acquire the mon job directory from the oraenv file if set.
if [ "$MON_JOB_DIR" = "" ]
then
  EXE_DIR=$HOME/wsl/mon/job
else
  EXE_DIR=$MON_JOB_DIR
fi

LOG_FILE=${LOG_DIR}/mon_$1.log
touch $LOG_FILE

JOB_POLL_SECONDS=0
let JOB_POLL_SECONDS="$JOB_POLL_MIN*60"
DB_POLL_SECONDS=0
let DB_POLL_SECONDS="$DB_POLL_MIN*60"
DB_STATUS=0

while ( true  )
do
   # Get the day of the month
   # If we have a new day then update the status in the database to indicate we are monitoring
   # If this process fails then it will notify if required and return the status
   # If changed monitoring info then a refresh of our tables occurs
   DAY_NO=`date +%d`
   if [ "$DAY_NO" -ne "$LAST_DAY_NO" ]
   then
     LAST_DAY_NO=$DAY_NO
     DB_STATUS=0
     PARAMS="$1 STATUS $MON_HOST $MON_VER $BACK_HOURS $BACK_MIN $LOG_LEVEL $JOB_POLL_MIN $DB_POLL_MIN"
     $BIN_DIR/ws_mon_db_010.sh $PARAMS >>$LOG_FILE 2>&1
     RES=$?
     if [ "$RES" -ne "0" ]
     then
       if [ "$RES" -eq "23" ]
       then
          STOP_MSG="Sqlplus had a non standard return code. Check unix logs"
       elif [ "$RES" -eq "24" ]
       then
          STOP_MSG="Sqlplus has failed. Check unix logs"
       elif [ "$RES" -eq "28" ]
       then
          STOP_MSG="Invalid number of notifys. Possibly due to Oracle down"
       else
          STOP_MSG=`echo "ws_mon_jobs_010.sh $1 returned a status of $RES" | tr " " "^"`
       fi
       echo "ws_mon_db_010.sh $1 returned a status of $RES"
       echo "The Monitor will terminate.."
       exit
     fi
   fi

   #
   # call job_mon. Returns are
   # 0 = job processed,   2 = no jobs,
   # 23 = sqlplus non standard return,   24 = sqlplus failed
   # 26 = invalid number of notifys. Could mean oracle is down
   #
   $BIN_DIR/ws_mon_jobs_010.sh $1 $BACK_HOURS $BACK_MIN $LOG_LEVEL $JOB_POLL_MIN >>$LOG_FILE 2>&1
   RES=$?
   if [ "$RES" -eq "2" ]
   then
      sleep $JOB_POLL_SECONDS
      let DB_STATUS="$DB_STATUS+$JOB_POLL_SECONDS"
   elif [ "$RES" -eq "0" ]
   then
      sleep $JOB_POLL_SECONDS
      let DB_STATUS="$DB_STATUS+$JOB_POLL_SECONDS"
   else
      date
      if [ "$RES" -eq "23" ]
      then
         STOP_MSG="Sqlplus had a non standard return code. Check unix logs"
      elif [ "$RES" -eq "24" ]
      then
         STOP_MSG="Sqlplus has failed. Check unix logs"
      elif [ "$RES" -eq "26" ]
      then
         STOP_MSG="Invalid number of notifys. Possibly due to Oracle down"
      else
         STOP_MSG=`echo "ws_mon_jobs_010.sh $1 returned a status of $RES" | tr " " "^"`
      fi
      echo "ws_mon_jobs_010.sh $1 returned a status of $RES"
      echo "The Monitor will terminate.."
      PARAMS="$1 FAIL $MON_HOST $MON_VER $BACK_HOURS $BACK_MIN $LOG_LEVEL $JOB_POLL_MIN $DB_POLL_MIN"
      $BIN_DIR/ws_mon_db_010.sh $PARAMS >>$LOG_FILE 2>&1
      exit
   fi

   #
   # If a database poll interval has expired then check
   # the database status
   #
   if [ "$DB_STATUS" -ge "$DB_POLL_SECONDS" ]
   then
     DB_STATUS=0
     PARAMS="$1 CHECK $MON_HOST $MON_VER $BACK_HOURS $BACK_MIN $LOG_LEVEL $JOB_POLL_MIN $DB_POLL_MIN"
     $BIN_DIR/ws_mon_db_010.sh $PARAMS >>$LOG_FILE 2>&1
     RES=$?
     if [ "$RES" -ne "0" ]
     then
       if [ "$RES" -eq "23" ]
       then
          STOP_MSG="Sqlplus had a non standard return code. Check unix logs"
       elif [ "$RES" -eq "24" ]
       then
          STOP_MSG="Sqlplus has failed. Check unix logs"
       elif [ "$RES" -eq "28" ]
       then
          STOP_MSG="Invalid number of notifys. Possibly due to Oracle down"
       else
          STOP_MSG=`echo "ws_mon_jobs_010.sh $1 returned a status of $RES" | tr " " "^"`
       fi
       echo "ws_mon_db_010.sh $1 returned a status of $RES"
       echo "The Monitor will terminate.."
       exit
     fi
   fi



done
exit
