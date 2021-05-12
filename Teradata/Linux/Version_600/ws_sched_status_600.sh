#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	ws_sched_status_600.sh
# Description 		:	Called by ws_sched_600.sh to update status
# Author 		:	Wayne Richmond
# Date			: 	05 April 2002
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# ============================================================================
# Notes / History
#
# ============================================================================
# WMR 05/04/2002    Version 1.0.7
# WMR 15/08/2003    Version 4.1.0
# WMR 01/03/2005    Version 4.1.1.3
# WMR 18/04/2007    Version 5.6.0
# WMR 02/07/2008    Version 6.0.0
# WMR 30/07/2008    Version 6.0.0.2
# JML 02/09/2008    Version 6.0.2
# RS  26/07/2012    Added ".exit" to bteq calls
# RS  27/07/2012    Added capture of btew warnings and errors into log-file

TDENV=$HOME/$1
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

STAT_FILE=${LOG_DIR}/sched_status_$1_`date +%Y%m%d`.log

MSG=`echo "$8" | tr "^" " "`

##
# Issue a command to update the status
##
RES1=`bteq <<EOF2 >/tmp/wsl_sched_status_600_$1.txt 2>&1
.logon ${DSS_BTEQDB}/${DSS_USER},${DSS_PWD}
CALL $DSS_METABASE.ws_sched_status('$2','$3','$4','$5','$MSG','$DSS_USER',$6,$7,0,?);
.exit
EOF2`
RES=$?

##
# Check that the bteq command worked.
#
if [ "$RES" -ne "0" ]
then
   echo "teradata returned a non standard return code from bteq of $?" >>$STAT_FILE
   echo "check the file /tmp/wsl_sched_status_600_$1.txt" >>$STAT_FILE
   exit
fi

##
# Check for  warning text as bteq exits with 0
##
BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`

if [ "$BTEQ_WARNING" != "" ]
then
   echo "teradata returned a non standard return code from bteq of $?" >>$STAT_FILE
   echo "check the file /tmp/wsl_sched_status_600_$1.txt" >>$STAT_FILE
   exit
fi
exit
