#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	ws_sched_status_411.sh
# Description 		:	Called by ws_sched_411.sh to update status
# Author 		:	Wayne Richmond
# Date			: 	05 April 2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# ============================================================================
# Notes / History
#
# ============================================================================
# WMR 05/04/2002    Version 1.0.7
# WMR 15/08/2003    Version 4.1.0
# WMR 01/03/2004    Version 4.1.1
# WMR 18/04/2007    Version 5.6.0

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

STAT_FILE=${LOG_DIR}/sched_status_$1_`date +%Y%m%d`.log

MSG=`echo "$8" | tr "^" " "`

##
# Issue a sqlplus command to update the status
##
sqlplus -s <<EOF| grep -v "completed" | grep -v "^$" >/tmp/ws_sched_status_560_$1.txt
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
variable x number;
exec :x := ws_sched_status('$2','$3','$4','$5','$MSG','$DSS_USER','$6','$7','0');
print :x
exit;
EOF

##
# Check that the sqlplus command worked.
# Often when sqlplus fails with an Oracle error it will echo
# the start of the command so we will see BEGIN... returned
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$STAT_FILE
   echo "check the file /tmp/ws_sched_status_560_$1.txt" >>$STAT_FILE
   exit
fi
RET_CHECK=`echo $RES | cut -d " " -f1`
if [ "$RET_CHECK" = "BEGIN" ]
then
   echo "Sqlplus failed with an oracle error. See logs" >>$STAT_FILE
   echo "check the file /tmp/ws_sched_status_560_$1.txt" >>$STAT_FILE
   exit -1
fi
exit
