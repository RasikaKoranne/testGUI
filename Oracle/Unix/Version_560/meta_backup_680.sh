#!/bin/bash
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# DBMS Name         :   Oracle
# Script Name       :   meta_backup_680.sh
# Description       :   Backup the WhereScape Meta Data
# Author            :   Ralph Schuster
# Date              :   27/02/2015
# Version           :   6.8.0
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# This version uses the data pump export executable expdp 
# It assumes that the scheduler and the Oracle server reside on the same server
#
# ============================================================================
# SETTINGS
#
ORAENV=$HOME/$1
# ============================================================================
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
TMP_DIR=/tmp/export
EXP_DIR=$HOME/wsl/export
#
LOG_FILE_NAME=meta_$1_`date +%Y%m%d%H%M`.log
PAR_FILE_NAME=meta_$1_`date +%Y%m%d%H%M`.par
EXP_FILE_NAME=meta_$1_`date +%Y%m%d%H%M`.exp
LOG_FILE=$EXP_DIR/$LOG_FILE_NAME
EXP_FILE=$EXP_DIR/$EXP_FILE_NAME
PAR_FILE=$EXP_DIR/$PAR_FILE_NAME
SEQ_FILE=$EXP_DIR/meta_$1_`date +%Y%m%d%H%M`.seq
DBL_FILE=$EXP_DIR/meta_$1_`date +%Y%m%d%H%M`.dbl
#
cd $HOME/wsl/export

#
# Create the temp directory for data pump if not existent
#
if [ ! -e $TMP_DIR ]
then
   mkdir $TMP_DIR
   if [ "$?" -ne "0" ]
   then
      echo "Could not create temporary folder $TMP_DIR" >>$LOG_FILE
      exit 1
   fi

   chmod 777 $TMP_DIR
   if [ "$?" -ne "0" ]
   then
      echo "Could not change access rights for temporary folder $TMP_DIR" >>$LOG_FILE
      exit 1
   fi
fi
#

#
# Check that we have the right to create a directory object in Oracle
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
# Get all the tables we wish to export
#
sqlplus -s <<! | grep -v "selected" | grep -v "^$" > $TMP_DIR/$PAR_FILE_NAME
$DSS_USER/$DSS_PWD
set pagesize 0
set trimspool on
select 'TABLES=',table_name from user_tables
where table_name like 'WS_%'
or table_name like 'DSS_%' order by table_name;
exit
!
#
# Check that the sqlplus command worked.
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi
#
#  Export the data
#
expdp $DSS_USER/$DSS_PWD logfile=$LOG_FILE_NAME parfile=$TMP_DIR/$PAR_FILE_NAME dumpfile=$EXP_FILE_NAME directory=tmp_dir 
RES=$?
cat $TMP_DIR/$LOG_FILE_NAME >> $LOG_FILE
#
if [ "$RES" -ne "0" ]
then
   echo "Expdb returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi
#
mv $TMP_DIR/$EXP_FILE_NAME $EXP_FILE
#
mv $TMP_DIR/$PAR_FILE_NAME $PAR_FILE

#
#
#  Save all the Sequences
#
sqlplus -s <<! | grep -v "selected" | grep -v "^$" | tr '\t' ' ' | tr -s ' ' > $SEQ_FILE
$DSS_USER/$DSS_PWD 
set pagesize 0
set trimspool on
select 'Drop Sequence ',sequence_name,';'
from user_sequences order by sequence_name;
exit
!
#
# Check that the sqlplus command worked.
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi

sqlplus -s <<! | grep -v "selected" | grep -v "^$" | tr '\t' ' ' | tr -s ' ' >> $SEQ_FILE
$DSS_USER/$DSS_PWD 
set pagesize 0
set linesize 256
set trimspool on
select 'Create Sequence ' a,sequence_name b,
       ' start with ' c,last_number d,' increment by ' e,increment_by f,';' g
from user_sequences order by sequence_name;
exit
!
#
# Check that the sqlplus command worked.
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi


#
#  Save all the Database Links
#
sqlplus -s <<! | grep -v "selected" | grep -v "^$" |  tr '\t' ' ' | tr -s ' ' > $DBL_FILE
$DSS_USER/$DSS_PWD 
set pagesize 0
set linesize 256
set trimspool on
select 'Drop Database Link ' a,db_link b,';' h
from user_db_links order by db_link;
exit
!
#
# Check that the sqlplus command worked.
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi

sqlplus -s <<! | grep -v "selected" | grep -v "^$" |  tr '\t' ' ' | tr -s ' ' >> $DBL_FILE
$DSS_USER/$DSS_PWD 
set pagesize 0
set linesize 256
set trimspool on
select 'Create Database Link ' a,db_link b,
       ' connect to ' c,username d,
       ' identified by "' e,password f,
       '" using ''' g,host,''';' h
from user_db_links order by db_link;
exit
!
#
# Check that the sqlplus command worked.
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?" >>$LOG_FILE
   exit 1
fi

exit 0
