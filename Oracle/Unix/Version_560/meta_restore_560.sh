#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	meta_restore.sh
# Description 		:	Restore the WhereScape Meta Data
# Author 			:	Wayne Richmond
# Date			: 	Version 1.0.0 22/01/2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# AP 09/05/2007    Version 5.6.0 Correct check for oraenv
# ============================================================================
# SETTINGS
#  Parameters are:
#  $1 - Oraenv to be restored.
#

SCRIPT_NAME=`basename $0`

if [ -z $1 ]
then
  echo Usage: $SCRIPT_NAME oraenv
  exit
fi

ORAENV=$HOME/$1
# ============================================================================
#
# Check that the environment file exists
#
if [ -r $ORAENV ]
then
   echo ""
else
   echo "Unable to locate environment file $ORAENV. No Action. Aborting"
   exit
fi

#
. $ORAENV
#

echo ""
echo ""
echo "WARNING    WARNING    WARNING    WARNING"
echo "You are about to delete and restore all the WhereScape meta data"
echo "Are You sure you wish to proceed (Y/N) <N> : \c"
read ans
if [ "$ans" !=  "Y" ]
then
   echo "NO action."
   exit
fi
#
# Get the file to restore
#
echo ""
echo "Enter the export file name (e.g. meta_200105151300 ) : \c"
read FNAME
#
LOG_FILE=$HOME/wsl/sched/log/restore_$1_`date +%Y%m%d%H%M`.log
LOG_FILE2=$HOME/wsl/sched/log/import_$1_`date +%Y%m%d%H%M`.log
SEQ_FILE=$HOME/wsl/export/$FNAME.seq
PAR_FILE=$HOME/wsl/export/$FNAME.par
DBL_FILE=$HOME/wsl/export/$FNAME.dbl
EXP_FILE=$HOME/wsl/export/$FNAME.exp
DRP_FILE=$HOME/wsl/export/$FNAME.drp
#
# Check that the files exist
#
if [ -r $EXP_FILE ]
then
   echo "export located .\c"
else
   echo "Unable to locate export file $EXP_FILE. No Action. Aborting"
   exit
fi

if [ -r $PAR_FILE ]
then
   echo ".\c"
else
   echo "Unable to locate export file $PAR_FILE. No Action. Aborting"
   exit
fi

if [ -r $DRP_FILE ]
then
   echo ".\c"
else
   echo "Unable to locate export file $DRP_FILE. No Action. Aborting"
   exit
fi

if [ -r $DBL_FILE ]
then
   echo ".\c"
else
   echo "Unable to locate export file $DBL_FILE. No Action. Aborting"
   exit
fi

if [ -r $SEQ_FILE ]
then
   echo ".\c"
else
   echo "Unable to locate export file $SEQ_FILE. No Action. Aborting"
   exit
fi
echo ""

#
# Now get the import user
#
echo ""
echo "Enter the Import username : \c"
read USER
echo "Enter the Import password : \c"
read PASSWD
#
cd $HOME/wsl/export

#
# Rebuild the Sequences and Links. Abort if a problem
#
echo "replacing db links ..."
sqlplus -s $USER/$PASSWD <$DBL_FILE > $LOG_FILE
if [ "$?" -ne "0" ]
then
   echo "Problem encountered with replacement of the db links"
   echo "See the log file $LOG_FILE"
   echo "Restore in Unknown state. Tables not restored !!!"
   exit
fi

#
echo " replacing sequences..."
sqlplus -s $USER/$PASSWD <$SEQ_FILE > $LOG_FILE
if [ "$?" -ne "0" ]
then
   echo "Problem encountered with replacement of the sequences"
   echo "See the log file $LOG_FILE"
   echo "Restore in Unknown state. Tables not restored !!!"
   exit
fi

#
# drop all the tables
echo " dropping tables..."
sqlplus -s $USER/$PASSWD <$DRP_FILE > $LOG_FILE
if [ "$?" -ne "0" ]
then
   echo "Problem encountered with dropping of meta tables"
   echo "See the log file $LOG_FILE"
   echo "Restore in Unknown state. Tables not restored !!!"
   exit
fi
#
# Perform the Import
#
imp $USER/$PASSWD parfile=$PAR_FILE touser=$USER log=$LOG_FILE2 file=$EXP_FILE 
exit
