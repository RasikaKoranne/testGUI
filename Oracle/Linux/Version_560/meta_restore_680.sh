#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name           :       meta_restore_680.sh
# Description           :       Restore the WhereScape Meta Data
# Author                :       Ralph Schuster
# Date                  :       27/02/2015
# Version               :       6.8.0 
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# =============================================================================
# Notes / History
#
# This version uses the data pump import executable impdp
# It assumes that the scheduler and the Oracle server reside on the same server
#
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
PROMPT="Are you sure you wish to proceed (yY/N) [N] : "
read -p "$PROMPT" ans
if [ "$ans" !=  "Y" -a "$ans" !=  "y" ]
then
   echo "NO action."
   exit
fi
#
# Get the file to restore
#
echo ""
PROMPT="Enter the export file name (e.g. meta_200105151300 ) : "
read -p "$PROMPT" FNAME
#
TMP_DIR=/tmp/export
EXP_DIR=$HOME/wsl/export
#
LOG_FILE_NAME=import_$1_`date +%Y%m%d%H%M`.log
EXP_FILE_NAME=$FNAME.exp

LOG_FILE=$EXP_DIR/$LOG_FILE_NAME
SEQ_FILE=$EXP_DIR/$FNAME.seq
DBL_FILE=$EXP_DIR/$FNAME.dbl
EXP_FILE=$EXP_DIR/$EXP_FILE_NAME
#
# Check that the files exist
#
if [ -r $EXP_FILE ]
then
   echo -ne "export located .\c"
else
   echo "Unable to locate export file $EXP_FILE. No Action. Aborting"
   exit 1
fi

if [ -r $DBL_FILE ]
then
   echo -ne ".\c"
else
   echo "Unable to locate export file $DBL_FILE. No Action. Aborting"
   exit 1
fi

if [ -r $SEQ_FILE ]
then
   echo -ne ".\c"
else
   echo "Unable to locate export file $SEQ_FILE. No Action. Aborting"
   exit 1
fi
echo ""

#
# Create the temp directory for data pump if not existent
#
if [ ! -e $TMP_DIR ]
then
   mkdir $TMP_DIR
    if [ "$?" -ne "0" ]
    then
       echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
       exit 1
    fi
fi
#
chmod 777 $TMP_DIR

#
# Get the import user and password
#
echo ""
PROMPT="Enter the Import user name : "
read -p "$PROMPT" USER
PROMPT="Enter the Import password : "
while IFS= read -p "$PROMPT" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
         break
    fi
    PROMPT='*'
    PASSWD+="$char"
done
#
echo
#
cd $EXP_DIR

#
# Check we have the right to create a directory object in Oracle
#
RES=`sqlplus -s <<! 
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
select to_char(count(*)) from USER_SYS_PRIVS WHERE PRIVILEGE = 'CREATE ANY DIRECTORY';
!
`
#
# Check that the sqlplus command worked.
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi
if [ "$RES" -ne "1" ]
then
   echo "Please ensure that the user has the right to create a directory object." >>$LOG_FILE
   exit 1
fi
#
# Create a directory object in Oracle
#
RES=`sqlplus -s <<! >>$LOG_FILE
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
CREATE OR REPLACE DIRECTORY tmp_dir AS '$TMP_DIR/';
!
`
#
# Check that the sqlplus command worked.
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi


#
# Get the owner/schema mapping
#
DEFAULT_OWNER=`echo $USER | tr  '[:lower:]' '[:upper:]'`
REMAP_SCHEMA_STRING=""
OWNER_LIST=`tr '[\000-\011\013-\037\177-\377]' '.' <$EXP_FILE | grep OWNER_NAME | awk -F "OWNER_NAME>" '{ print substr($2,1,length($2) - 2) }' | sort -u`
#
for I in $OWNER_LIST
do
   PROMPT="Map table owner $I to [$DEFAULT_OWNER] : "
   read -p "$PROMPT" NEW_OWNER
   
   NEW_OWNER=${NEW_OWNER:=$DEFAULT_OWNER}
   REMAP_SCHEMA_STRING=`echo $REMAP_SCHEMA_STRING " " REMAP_SCHEMA=$I:$NEW_OWNER`
done


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
   exit 1
fi
#
echo " replacing sequences..."
sqlplus -s $USER/$PASSWD <$SEQ_FILE > $LOG_FILE
if [ "$?" -ne "0" ]
then
   echo "Problem encountered with replacement of the sequences"
   echo "See the log file $LOG_FILE"
   echo "Restore in Unknown state. Tables not restored !!!"
   exit 1
fi

#
# Copy the exported file to the temporary data pump location 
#
cp $EXP_FILE $TMP_DIR > $LOG_FILE 2>&1
if [ "$?" -ne "0" ]
then
   echo "Could not copy the exported file to the temporary data pump location"
   echo "See the log file $LOG_FILE"
   echo "Restore in Unknown state. Tables not restored !!!"
   exit 1
fi
#
chmod 744 $TMP_DIR/$EXP_FILE_NAME

#
# Perform the Import
#
impdp $USER/$PASSWD $REMAP_SCHEMA_STRING logfile=$LOG_FILE_NAME dumpfile=$EXP_FILE_NAME directory=tmp_dir table_exists_action=replace
RES=$?
cat $TMP_DIR/$LOG_FILE_NAME >> $LOG_FILE
#
if [ "$RES" -ne "0" ]
then
   echo "Problem encountered with import of meta tables"
   echo "See the log file $LOG_FILE"
   echo "Restore in Unknown state. Tables not restored !!!"
   exit 1
fi

exit 0
