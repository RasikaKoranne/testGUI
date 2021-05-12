#!/bin/ksh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Database Server Name	:	
# Database Name 	:
# Script Name 		:	cleanup.sh
# Description 		:	Remove extraneous WhereScape files
# Author 		:	Wayne Richmond
# Date			: 	Version 1.0.0   22/01/2002
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# =============================================================================
# Notes / History
#
# JML 15/04/2012  Teradata UNIX Version
# RS  26/09/2013  Changed to use variables for all directories
# RS  10/03/2015  V6.8.3.1   Added check for accessibility of the folders
# RS  15/10/2015  V6.8.4.4   Fixed variable spelling error
#
# =============================================================================


SCRIPT_NAME=`basename $0`

if [ -z $1 ]
then
  echo Usage: $SCRIPT_NAME tdenv
  exit
fi

TDENV=$HOME/$1
# ============================================================================
#
# Check that the environment file exists
#
if [ -r $TDENV ]
then
   echo ""
else
   echo "Unable to locate environment file $TDENV. No Action. Aborting"
   exit
fi

. $TDENV


# =============================================================================
# Export cleanup
# ============================================================================
# Delete all files in export more than 9 days old
#
if [ "$WSL_EXP_DIR" != "" -a -x "$WSL_EXP_DIR" ]
then
  find $WSL_EXP_DIR -type f ! -mtime -9 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$WSL_EXP_DIR\" (WSL_EXP_DIR)."
fi

#
# Delete all files in expback more than 60 days old
#
if [ "$WSL_EXP_BUP" != "" -a -x "$WSL_EXP_BUP" ]
then
  find $WSL_EXP_BUP -type f ! -mtime -60 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$WSL_EXP_BUP\" (WSL_EXP_BUP)."
fi

#
# =============================================================================
# Job and job log cleanup
# ============================================================================
#
# Delete all files in job more than 7 days old
#
if [ "$JOB_EXE_DIR" != "" -a -x "$JOB_EXE_DIR" ]
then
  find $JOB_EXE_DIR -type f ! -mtime -7 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$JOB_EXE_DIR\" (JOB_EXE_DIR)."
fi

#
# Delete all files in job log more than 7 days old
#
if [ "$JOB_LOG_DIR" != "" -a -x "$JOB_LOG_DIR" ]
then
  find $JOB_LOG_DIR -type f ! -mtime -7 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$JOB_LOG_DIR\" (JOB_LOG_DIR)."
fi

#
# =============================================================================
# Log cleanup
# ============================================================================
#
# Delete all files in log more than 60 days old
#
if [ "$WSL_LOG_DIR" != "" -a -x "$WSL_LOG_DIR" ]
then
  find  $WSL_LOG_DIR -type f ! -mtime -60 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$WSL_LOG_DIR\" (WSL_LOG_DIR)."
fi

#
# =============================================================================
# Temporary file cleanup
# ============================================================================
#
# Delete all files in work directory more than 30 days old
#
if [ "$WSL_WORK_DIR" != "" -a -x "$WSL_WORK_DIR" ]
then
  find $WSL_WORK_DIR -name "wsl*" ! -mtime -30 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$WSL_WORK_DIR\" (WSL_WORK_DIR)."
fi

#
# =============================================================================
# Monitor job and log cleanup
# ============================================================================
#
# Delete all files in mon job more than 7 days old
#
if [ "$MON_JOB_DIR" != "" -a -x "$MON_JOB_DIR" ]
then
  find $MON_JOB_DIR -type f ! -mtime -7 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$MON_JOB_DIR\" (MON_JOB_DIR)."
fi

#
# Delete all files in mon db more than 7 days old
#
if [ "$MON_DB_DIR" != "" -a -x "$MON_DB_DIR" ]
then
  find $MON_DB_DIR -type f ! -mtime -7 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$MON_DB_DIR\" (MON_DB_DIR)."
fi

#
# Delete all files in mon log more than 60 days old
#
if [ "$MON_LOG_DIR" != "" -a -x "$MON_LOG_DIR" ]
then
  find  $MON_LOG_DIR -type f ! -mtime -60 -exec rm {} \;
else
  echo "Warning: Cannot access directory \"$MON_LOG_DIR\" (MON_LOG_DIR)."
fi

exit