#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	ws_mon_check_010.sh
# Description 		:	Cron job run regularly to check and if required
#                               Start the monitor process
# Author 		:	Wayne Richmond
# Date			: 	3 October 2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# ============================================================================
# Notes / History
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


ps -efw >/tmp/ws_mon_010_$1.txt
CNT=`cat /tmp/ws_mon_010_$1.txt | grep ws_mon_010 | grep $1 | wc -l`

if [ "$CNT" -lt "1" ]
then
   echo " "
   echo "Starting monitor $1 `date`"
   echo "Starting monitor $1 `date`" >>$LOG_DIR/mon_$1.log 2>&1
   nohup $BIN_DIR/ws_mon_start_010.sh $1 >>$LOG_DIR/mon_$1.log 2>&1 &
fi

exit
