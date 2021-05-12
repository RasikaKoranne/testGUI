#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
#
# WMR 01/03/2005    Version 4.1.1.3
# WMR 18/04/2007    Version 5.6.0.0

ORAENV=$HOME/$1
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


nohup $BIN_DIR/ws_sched_560.sh $1 >> $LOG_DIR/sched_$1.log 2>&1 &
