#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 	:	ws_mon_db_010.sh
# Description 	:	Monitor database and Notify if required
# Author 		:	Wayne Richmond
# Date			: 	Version 1.0.0  03/10/2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# option=$2, mon_host=$3, mon_ver=$4, back_hh=$5, back_mm=$6
# log_level=$7, job_poll_min=$8, db_poll_min=$9
#
# WMR  15/08/2003  Version 4.1 put variables back in oraenv
#
# ============================================================================
ORAENV=$HOME/$1
. $ORAENV

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

# Note: acquire the mon db directory from the oraenv file if set.
if [ "$MON_DB_DIR" = "" ]
then
  EXE_DIR=$HOME/wsl/mon/db
else
  EXE_DIR=$MON_DB_DIR
fi

LOG_FILE=${LOG_DIR}/mon_$1.log

#
# Three possible scenario's
# 1. We have had a failure in our job monitoring so are here to confirm a DB down
# 2. We are providing a status update so that the DW knows a monitor is running
# 3. We have a regular scheduled check of the database and our monitoring info
#
# If the databse is okay then we will update the monitoring info held outside
# the database if there has been a change
#
# If the database is not responding then check to see if we need to notify
#
# If database is okay then check to see if we have a scheduler test
#

#
# See if we have monitoring enabled for the scheduler and database
# for this day
#
DAY_NAME=`date +%a`
DAY_TIME=`date +%H%M`
UNIX_NAME=${EXE_DIR}/unix_${DAY_NAME}
if [ -r $UNIX_NAME ]
then
    UNIX_MON=1
else
    UNIX_MON=0
fi
WIN_NAME=${EXE_DIR}/win_${DAY_NAME}
if [ -r $WIN_NAME ]
then
    WIN_MON=1
else
    WIN_MON=0
fi
DB_NAME=${EXE_DIR}/db_${DAY_NAME}
if [ -r $DB_NAME ]
then
    DB_MON=1
else
    DB_MON=0
fi

#
# Do a status check or update
#
RES=`sqlplus -s <<EOF| grep -v "completed" | grep -v "^$" | tr -s "\n" "~"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
variable x number;
variable v_unix_sched number;
variable v_win_sched number;
exec :x := ws_mon_status('$2','$3','$4','UNIX',$5,$6,$7,$8,$9,:v_unix_sched, :v_win_sched);
print :x :v_unix_sched :v_win_sched;
exit;
EOF`

##
# Check that the sqlplus command worked.
# Often when sqlplus fails with an Oracle error it will echo
# the start of the command so we will see BEGIN... returned
# If a failure then exit with a failure to force the scheduler to stop
# This prevents recursurve errors every 30 seconds
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?"
   echo "$RES"
   echo "Aborting monitor...."
   #
   # if we have database monitoring then see if we need to notify
   #
   if [ "$DB_MON" -eq "1" ]
   then
     $BIN_DIR/ws_mon_notify_010.sh $1 db $DAY_NAME $DAY_TIME>>$LOG_FILE 2>&1
   fi
   exit 23
fi
RET_CHECK=`echo $RES | cut -d " " -f1`
RET_CHECK2=`echo $RET_CHECK | cut -d ":" -f1`
if [ "$RET_CHECK" = "BEGIN" -o "$RET_CHECK2" = "ERROR" ]
then
   echo "Sqlplus failed with an oracle error."
   echo "$RES"
   echo "Aborting monitor...."
   #
   # if we have database monitoring then see if we need to notify
   #
   if [ "$DB_MON" -eq "1" ]
   then
     $BIN_DIR/ws_mon_notify_010.sh $1 db $DAY_NAME $DAY_TIME>>$LOG_FILE 2>&1
   fi
   exit 24
fi

#
# Set up all our parameter variables
#
UPDATE_IND=`echo $RES | cut -d "~" -f1`
UNIX_SCHED=`echo $RES | cut -d "~" -f2`
WIN_SCHED=`echo $RES | cut -d "~" -f3`
# echo "Update_ind: $UPDATE_IND"
# echo "Unix: $UNIX_SCHED"
# echo "Win: $WIN_SCHED"

#
# make sure we got a valid response otherwise assume db down
#
if [ "$UPDATE_IND" != "2" -a "$UPDATE_IND" != "1" ]
then
   echo "Sqlplus failed to return a valid response from procedure"
   echo "$RES"
   echo "Aborting monitor...."
   #
   # if we have database monitoring then see if we need to notify
   #
   if [ "$DB_MON" -eq "1" ]
   then
     $BIN_DIR/ws_mon_notify_010.sh $1 db $DAY_NAME $DAY_TIME>>$LOG_FILE 2>&1
   fi
   exit 24
fi

#
# see if an update of our scripts is required
#
if [ "$UPDATE_IND" -eq "2" ]
then
    $BIN_DIR/ws_mon_refresh_010.sh $1 >>$LOG_FILE 2>&1
fi

#
# if we have scheduler monitoring then see if we need to notify
#
if [ "$UNIX_MON" -eq "1" ]
then
  if [ "$UNIX_SCHED" -eq "0" ]
  then
    $BIN_DIR/ws_mon_notify_010.sh $1 unix $DAY_NAME $DAY_TIME>>$LOG_FILE 2>&1
  fi
fi
if [ "$WIN_MON" -eq "1" ]
then
  if [ "$WIN_SCHED" -eq "0" ]
  then
    $BIN_DIR/ws_mon_notify_010.sh $1 win $DAY_NAME $DAY_TIME>>$LOG_FILE 2>&1
  fi
fi


exit
