#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name 	:	ws_mon_refresh_010.sh
# Description 	:	Monitor refresh of tables used for db monitoring
# Author 		:	Wayne Richmond
# Date			: 	Version 1.0.0  03/10/2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# WMR  15/08/2003   Version 4.1 Put all variables back in the oraenv file
# ============================================================================
ORAENV=$HOME/$1
. $ORAENV

# Note: acquire the bin directory from the oraenv file if set.
if [ "$WSL_BIN_DIR" = "" ]
then
  BIN_DIR=$HOME/wsl/bin
else
  BIN_DIR=$WSL_BIN_DIR
fi

# Note: acquire the mon log directory from the oraenv file if set.
if [ "$MON_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/mon/log
else
  LOG_DIR=$MON_LOG_DIR
fi

# Note: acquire the mon db directory from the oraenv file if set.
if [ "$MON_DB_DIR" = "" ]
then
  EXE_DIR=$HOME/wsl/mon/db
else
  EXE_DIR=$MON_DB_DIR
fi

LOG_FILE=${LOG_DIR}/mon_$1.log

ORES=0

echo "`date` Updating scrips and command files for db monitoring" >>${LOG_FILE}

# =============================================
# Get the scripts for db, and scheduler notify
# May be empty
# =============================================
sqlplus -s <<EOF | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015" >$EXE_DIR/db_script.sh
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select sl_line from ws_scr_line
Where sl_obj_key = ( Select wmd_db_script_key from ws_wrk_mon_db );
exit;
EOF
if [ "$?" -ne "0" ]
then ORES="$?"
fi

chmod 750 $EXE_DIR/db_script.sh

sqlplus -s <<EOF1 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015" >$EXE_DIR/unix_script.sh
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select sl_line from ws_scr_line
Where sl_obj_key = ( Select wmd_unix_script_key from ws_wrk_mon_db );
exit;
EOF1
if [ "$?" -ne "0" ]
then ORES="$?"
fi


chmod 750 $EXE_DIR/unix_script.sh

sqlplus -s <<EOF2 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015" >$EXE_DIR/win_script.sh
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select sl_line from ws_scr_line
Where sl_obj_key = ( Select wmd_win_script_key from ws_wrk_mon_db );
exit;
EOF2
if [ "$?" -ne "0" ]
then ORES="$?"
fi


chmod 750 $EXE_DIR/win_script.sh

# =============================================
# Get the script keys
# =============================================
DB_KEY=`sqlplus -s <<EOF3 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select nvl(wmd_db_script_key,0) from ws_wrk_mon_db;
exit;
EOF3`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

UNIX_KEY=`sqlplus -s <<EOF4 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select nvl(wmd_unix_script_key,0) from ws_wrk_mon_db;
exit;
EOF4`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

WIN_KEY=`sqlplus -s <<EOF5 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select nvl(wmd_win_script_key,0) from ws_wrk_mon_db;
exit;
EOF5`
if [ "$?" -ne "0" ]
then ORES="$?"
fi



# =============================================
# Get the parameters for
# DATABASE
# =============================================
DB_PARAM1=`sqlplus -s <<EOF6 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_db_param1 from ws_wrk_mon_db;
exit;
EOF6`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

DB_PARAM2=`sqlplus -s <<EOF7 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_db_param2 from ws_wrk_mon_db;
exit;
EOF7`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

DB_PARAM3=`sqlplus -s <<EOF8 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_db_param3 from ws_wrk_mon_db;
exit;
EOF8`
if [ "$?" -ne "0" ]
then ORES="$?"
fi



# =============================================
# Get the parameters for
# UNIX
# =============================================
UNIX_PARAM1=`sqlplus -s <<EOF9 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_unix_param1 from ws_wrk_mon_db;
exit;
EOF9`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

UNIX_PARAM2=`sqlplus -s <<EOF10 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_unix_param2 from ws_wrk_mon_db;
exit;
EOF10`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

UNIX_PARAM3=`sqlplus -s <<EOF11 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_unix_param3 from ws_wrk_mon_db;
exit;
EOF11`
if [ "$?" -ne "0" ]
then ORES="$?"
fi



# =============================================
# Get the parameters for
# WIN
# =============================================
WIN_PARAM1=`sqlplus -s <<EOF12 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_win_param1 from ws_wrk_mon_db;
exit;
EOF12`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

WIN_PARAM2=`sqlplus -s <<EOF13 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_win_param2 from ws_wrk_mon_db;
exit;
EOF13`
if [ "$?" -ne "0" ]
then ORES="$?"
fi

WIN_PARAM3=`sqlplus -s <<EOF14 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
select wmd_win_param3 from ws_wrk_mon_db;
exit;
EOF14`
if [ "$?" -ne "0" ]
then ORES="$?"
fi


# =============================================
# Create the notify files for each period
# and type
# =============================================
if [ "$DB_KEY" -eq "0" ]
then
    DBS=""
else
    DBS=$EXE_DIR/db_script.sh
fi
if [ "$UNIX_KEY" -eq "0" ]
then
    UNIXS=""
else
    UNIXS=$EXE_DIR/unix_script.sh
fi
if [ "$WIN_KEY" -eq "0" ]
then
    WINS=""
else
    WINS=$EXE_DIR/win_script.sh
fi
echo "$DBS $DB_PARAM1" >$EXE_DIR/db_notify1.sh
echo "$DBS $DB_PARAM2" >$EXE_DIR/db_notify2.sh
echo "$DBS $DB_PARAM3" >$EXE_DIR/db_notify3.sh
echo "$UNIXS $UNIX_PARAM1" >$EXE_DIR/unix_notify1.sh
echo "$UNIXS $UNIX_PARAM2" >$EXE_DIR/unix_notify2.sh
echo "$UNIXS $UNIX_PARAM3" >$EXE_DIR/unix_notify3.sh
echo "$WINS $WIN_PARAM1" >$EXE_DIR/win_notify1.sh
echo "$WINS $WIN_PARAM2" >$EXE_DIR/win_notify2.sh
echo "$WINS $WIN_PARAM3" >$EXE_DIR/win_notify3.sh

chmod 750 $EXE_DIR/db_notify1.sh
chmod 750 $EXE_DIR/db_notify2.sh
chmod 750 $EXE_DIR/db_notify3.sh
chmod 750 $EXE_DIR/unix_notify1.sh
chmod 750 $EXE_DIR/unix_notify2.sh
chmod 750 $EXE_DIR/unix_notify3.sh
chmod 750 $EXE_DIR/win_notify1.sh
chmod 750 $EXE_DIR/win_notify2.sh
chmod 750 $EXE_DIR/win_notify3.sh

# =============================================
# Get the monitor activity for each day for
# each type
# =============================================
  for TYPE in db unix win
  do
    for DAY_NO in 1 2 3 4 5 6 7
    do
      NCOUNT=`sqlplus -s <<EOF15 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
      $DSS_USER/$DSS_PWD
      set sqlprompt "";
      set heading off;
      set pagesize 0
      set linesize 256
      set trimspool on
      set echo off;
      select count(1) from ws_wrk_mon_db
      where substr(wmd_${TYPE}_1,${DAY_NO},1) = 'Y'
      or substr(wmd_db_2,${DAY_NO},1) = 'Y'
      or substr(wmd_db_3,${DAY_NO},1) = 'Y';
      exit;
EOF15`
      if [ "$?" -ne "0" ]
      then ORES="$?"
      fi

      if [ "$NCOUNT" -eq "0" ]
      then
        rm -f $EXE_DIR/db_mon
      else
        if [ "$DAY_NO" -eq "1" ]
        then DAY="Mon"
        elif [ "$DAY_NO" -eq "2" ]
        then DAY="Tue"
        elif [ "$DAY_NO" -eq "3" ]
        then DAY="Wed"
        elif [ "$DAY_NO" -eq "4" ]
        then DAY="Thu"
        elif [ "$DAY_NO" -eq "5" ]
        then DAY="Fri"
        elif [ "$DAY_NO" -eq "6" ]
        then DAY="Sat"
        elif [ "$DAY_NO" -eq "7" ]
        then DAY="Sun"
        fi
        sqlplus -s <<EOF16 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015" >$EXE_DIR/${TYPE}_${DAY}
        $DSS_USER/$DSS_PWD
        set sqlprompt "";
        set heading off;
        set pagesize 0
        set linesize 256
        set trimspool on
        set echo off;
        select lpad(nvl(( select wmd_${DAY}_from_1
        from ws_wrk_mon_db
        where substr(wmd_${TYPE}_1,${DAY_NO},1) = 'Y'),0),4,'0') from dual;
        select lpad(nvl(( select wmd_${DAY}_till_1
        from ws_wrk_mon_db
        where substr(wmd_${TYPE}_1,${DAY_NO},1) = 'Y'),0),4,'0') from dual;
        select lpad(nvl(( select wmd_${DAY}_from_2
        from ws_wrk_mon_db
        where substr(wmd_${TYPE}_2,${DAY_NO},1) = 'Y'),0),4,'0') from dual;
        select lpad(nvl(( select wmd_${DAY}_till_2
        from ws_wrk_mon_db
        where substr(wmd_${TYPE}_2,${DAY_NO},1) = 'Y'),0),4,'0') from dual;
        select lpad(nvl(( select wmd_${DAY}_from_3
        from ws_wrk_mon_db
        where substr(wmd_${TYPE}_3,${DAY_NO},1) = 'Y'),0),4,'0') from dual;
        select lpad(nvl(( select wmd_${DAY}_till_3
        from ws_wrk_mon_db
        where substr(wmd_${TYPE}_3,${DAY_NO},1) = 'Y'),0),4,'0') from dual;
        exit;
EOF16
        if [ "$?" -ne "0" ]
        then ORES="$?"
        fi

      fi
    done
  done

#
# If the overall status is still zero
# then it all worked okay so update the timestamp to show
# we have retrieved the info
#
if [ "$ORES" -eq "0" ]
then
    RES=`sqlplus -s <<EOF20 | grep -v "rows selected.$" | grep -v "^$" | tr -d "\015"
    $DSS_USER/$DSS_PWD
    set sqlprompt "";
    set heading off;
    set pagesize 0
    set linesize 256
    set trimspool on
    set echo off;
    update ws_wrk_mon_status
    set wms_last_script_update=sysdate;
    exit;
EOF20`
fi
exit
