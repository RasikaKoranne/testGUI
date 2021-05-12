#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# DBMS Name 		:	Oracle
# Script Name 		:	meta_backup_010.sh
# Description 		:	Backup the WhereScape Meta Data
# Author 		:	Wayne Richmond
# Date			: 	Version 1.0.0  22/01/2002
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# =============================================================================
# Notes / History
#
# ============================================================================
# SETTINGS
#
ORAENV=$HOME/$1
# ============================================================================
. $ORAENV
LOG_FILE=$HOME/wsl/sched/log/meta_$1_`date +%Y%m%d%H%M`.log
PAR_FILE=$HOME/wsl/export/meta_$1_`date +%Y%m%d%H%M`.par
SEQ_FILE=$HOME/wsl/export/meta_$1_`date +%Y%m%d%H%M`.seq
DBL_FILE=$HOME/wsl/export/meta_$1_`date +%Y%m%d%H%M`.dbl
EXP_FILE=$HOME/wsl/export/meta_$1_`date +%Y%m%d%H%M`.exp
DRP_FILE=$HOME/wsl/export/meta_$1_`date +%Y%m%d%H%M`.drp
#
cd $HOME/wsl/export
#
# Get all the tables we wish to export
#
sqlplus -s <<! | grep -v "selected" | grep -v "^$" > $PAR_FILE
$DSS_USER/$DSS_PWD
set pagesize 0
set trimspool on
select 'TABLES=',table_name from user_tables
where table_name like 'WS_%'
or table_name like 'DSS_%' order by table_name;
exit
!
#
#
# Create a drop table command file
#
cat $PAR_FILE | sed 's/TABLES=/Drop Table /;s/$/;/' > $DRP_FILE
#
#
#  Export the data
#
exp $DSS_USER/$DSS_PWD log=$LOG_FILE parfile=$PAR_FILE file=$EXP_FILE <<EOF
EOF

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

# ed $DBL_FILE < $HOME/wsl/bin/dbl_fix.cmd

exit
