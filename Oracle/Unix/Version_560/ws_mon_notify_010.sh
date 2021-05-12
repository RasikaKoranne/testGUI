#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 	:	ws_mon_notify_010.sh
# Description 	:	Notify requested. Proceed if active for this day
# Author 		:	Wayne Richmond
# Date			: 	Version 1.0.0  03/10/2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# WMR  15/08/2003   Version 4.1 Put variables back in oraenv
# ============================================================================
ORAENV=$HOME/$1
NOTIFY_TYPE=$2
DAY_NAME=$3
DAY_TIME=$4

. $ORAENV

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

FILE_NAME=${EXE_DIR}/${NOTIFY_TYPE}_${DAY_NAME}

#
# read the contents of the control file for the day and type specified
#
START1=`cat ${FILE_NAME} | head -1`
STOP1=`cat ${FILE_NAME} | head -2 | tail -1`
START2=`cat ${FILE_NAME} | head -3 | tail -1`
STOP2=`cat ${FILE_NAME} | head -4 | tail -1`
START3=`cat ${FILE_NAME} | head -5 | tail -1`
STOP3=`cat ${FILE_NAME} | head -6 | tail -1`

#
# work out which checks are active
#
if [ "$START1" -eq "$STOP1" ]
then CHECK1=0
else CHECK1=1
fi
if [ "$START2" -eq "$STOP2" ]
then CHECK2=0
else CHECK2=1
fi
if [ "$START3" -eq "$STOP3" ]
then CHECK3=0
else CHECK3=1
fi

# If check 1 is active then see if a notify is required
if [ "$CHECK1" -eq "1" ]
then
  if [ "$DAY_TIME" -ge "$START1" ]
  then
    if [ "$DAY_TIME" -le "$STOP1" ]
    then
      #
      # in the check time so perform the notify
      #
      echo "`date` ${NOTIFY_TYPE} notification for period 1 sent"
      ${EXE_DIR}/${NOTIFY_TYPE}_notify1.sh >>${LOG_FILE} 2>&1
      CHECK2=0
      CHECK3=0
    fi
  fi
fi

# If check 2 is active then see if a notify is required
if [ "$CHECK2" -eq "1" ]
then
  if [ "$DAY_TIME" -ge "$START2" ]
  then
    if [ "$DAY_TIME" -le "$STOP2" ]
    then
      #
      # in the check time so perform the notify
      #
      echo "`date` ${NOTIFY_TYPE} notification for period 2 sent"
      ${EXE_DIR}/${NOTIFY_TYPE}_notify2.sh >>${LOG_FILE} 2>&1
      CHECK3=0
    fi
  fi
fi

# If check 3 is active then see if a notify is required
if [ "$CHECK3" -eq "1" ]
then
  if [ "$DAY_TIME" -ge "$START3" ]
  then
    if [ "$DAY_TIME" -le "$STOP3" ]
    then
      #
      # in the check time so perform the notify
      #
      echo "`date` ${NOTIFY_TYPE} notification for period 3 sent"
      ${EXE_DIR}/${NOTIFY_TYPE}_notify3.sh >>${LOG_FILE} 2>&1
    fi
  fi
fi



exit
