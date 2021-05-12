#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 		:	meta_archive_010.sh
# Description 		:	Archive the WhereScape Meta Data Backups
# Author 		:	Wayne Richmond
# Date			: 	Version 1.0.0  22/01/2002
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2016
# =============================================================================
# Notes / History
#
# ============================================================================
# SETTINGS
#
# ============================================================================
LOG_FILE=$HOME/wsl/sched/log/tar_`date +%Y%m%d`.log
TAR_FILE=$HOME/wsl/expback/meta_`date +%Y%m%d`.tar
#
cd $HOME/wsl/export
touch $LOG_FILE
#
# Build the tar file
#
tar -cvf $TAR_FILE . >>$LOG_FILE
if [ "$?" -ne "0" ]
then
    echo "tar failed"
    exit
fi

#
# Compress the tar file
#
compress $TAR_FILE  >>$LOG_FILE
if [ "$?" -ne "0" ]
then
    echo "tar compress failed"
    exit
fi


#
# Looks like the tar file worked so delete the exports
#
cd $HOME/wsl/export 
rm *.seq >>$LOG_FILE
rm *.dbl >>$LOG_FILE
rm *.par >>$LOG_FILE
rm *.exp >>$LOG_FILE
rm *.drp >>$LOG_FILE

exit