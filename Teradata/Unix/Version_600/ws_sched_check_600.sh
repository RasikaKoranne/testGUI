#!/bin/ksh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	ws_sched_check_600.sh
# Description 		:	Cron job run regularly to check and if required
#                               Start the scheduler
# Author 		:	WhereScape
# Date			: 	10 May 2001
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# ============================================================================
# Notes / History
#
# ============================================================================
# WMR 22/01/2002    Version 1.0.0
# WMR 08/10/2002    Version 1.2.1
# WMR 15/08/2003    Version 4.1.0
# WMR 01/03/2005    Version 4.1.1.3
# WMR 18/04/2007    Version 5.6.0
# WMR 02/07/2008    Version 6.0.0
# JML 01/09/2008    Version 6.0.2
# JML 15/04/2012    Version 6.7.1   Teradata UNIX Version

TDENV=$HOME/$1
. $HOME/.profile
. $TDENV

# Note: acquire the bin directory from the dbenv file if set.
if [ "$WSL_BIN_DIR" = "" ]
then
  BIN_DIR=$HOME/wsl/bin
else
  BIN_DIR=$WSL_BIN_DIR
fi
# Note: acquire the log directory from the dbenv file if set.
if [ "$WSL_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/sched/log
else
  LOG_DIR=$WSL_LOG_DIR
fi


ps -ef >/tmp/ws_sched_600_$1.txt
CNT=`cat /tmp/ws_sched_600_$1.txt | grep ws_sched_600 | grep $1 | wc -l`

if [ "$CNT" -lt "1" ]
then
   echo " "
   echo "Starting scheduler $1 `date`"
   echo "Starting scheduler $1 `date`" >>$LOG_DIR/sched_$1.log 2>&1
   nohup $BIN_DIR/ws_start_600.sh $1 >>$LOG_DIR/sched_$1.log 2>&1 &
#   cat /tmp/ws_sched_600_$1.txt >>$LOG_DIR/sched_$1.log
fi

exit
