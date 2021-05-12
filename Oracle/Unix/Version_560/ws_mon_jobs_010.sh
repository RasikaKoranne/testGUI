#!/bin/ksh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# DBMS Name         : Oracle
# Script Name       : ws_mon_jobs.sh
# Description       : Checks all jobs being monitored and executes notify
# Author            : Wayne Richmond
# Date              : Version 1.2.1 1/10/2002
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2016
# =============================================================================
# Notes / History
#
# Positional parameters are 1 = oraenv file name
#
# WMR 15/08/2003   Version 4.1 Put variables back in oraenv file 
# HM  12/03/2015   Version 6.8.3.2 Add support for Hadoop scripts
# ============================================================================
# SETTINGS
#
ORAENV=$HOME/$1
RUNSHELL=ksh
BACK_HOURS=$2
BACK_MINUTES=$3
LOG_LEVEL=$4
POLL_MINUTES=$5
# ============================================================================
. $ORAENV

# Note: acquire the mon log directory from the oraenv file if set.
if [ "$MON_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/mon/log
else
  LOG_DIR=$MON_LOG_DIR
fi

# Note: acquire the mon job directory from the oraenv file if set.
if [ "$MON_JOB_DIR" = "" ]
then
  EXE_DIR=$HOME/wsl/mon/job
else
  EXE_DIR=$MON_JOB_DIR
fi

##
# Issue a sqlplus command to get the notify counter
##

RES=`sqlplus -s <<WS010EOF| grep -v "completed" | grep -v "^$" | tr -s "\n" "~"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
variable x number;
variable job_count number;
exec :x := ws_mon_job_check($BACK_HOURS, $BACK_MINUTES, $POLL_MINUTES, $LOG_LEVEL, :job_count);
print :job_count;
exit;
WS010EOF`

##
# Check that the sqlplus command worked.
# Often when sqlplus fails with an Oracle error it will echo
# the start of the command so we will see BEGIN... returned
# If a failure then exit with a failure to force the scheduler to stop
# This prevents recursurve errors every 30 seconds
#
if [ "$?" -ne "0" ]
then
   echo "Sqlplus returned a non standard return code of $?"
   echo "$RES"
   echo "Aborting monitor...."
   exit 23
fi
RET_CHECK=`echo $RES | cut -d " " -f1`
if [ "$RET_CHECK" = "BEGIN" ]
then
   echo "Sqlplus failed with an oracle error. See logs"
   echo "$RES"
   echo "Aborting monitor...."
   exit 24
fi

#
# Set up all our parameter variables
#
JOB_COUNT=`echo $RES | cut -d "~" -f1`

#
# If no jobs to notify for then exit
#
if [ "$JOB_COUNT" = "0" ]
then
    echo "`date` No notifications required"
    exit 2
fi


#
# check that job count is between 1 and 9
# if not then abort
#
if [ "$JOB_COUNT" = "1" ]
then
  NOTIFY_LIST="1"
elif [ "$JOB_COUNT" = "2" ]
then
  NOTIFY_LIST="1 2"
elif [ "$JOB_COUNT" = "3" ]
then
  NOTIFY_LIST="1 2 3"
elif [ "$JOB_COUNT" = "4" ]
then
  NOTIFY_LIST="1 2 3 4"
elif [ "$JOB_COUNT" = "5" ]
then
  NOTIFY_LIST="1 2 3 4 5"
elif [ "$JOB_COUNT" = "6" ]
then
  NOTIFY_LIST="1 2 3 4 5 6"
elif [ "$JOB_COUNT" = "7" ]
then
  NOTIFY_LIST="1 2 3 4 5 6 7"
elif [ "$JOB_COUNT" = "8" ]
then
  NOTIFY_LIST="1 2 3 4 5 6 7 8"
elif [ "$JOB_COUNT" = "9" ]
then
  NOTIFY_LIST="1 2 3 4 5 6 7 8 9"
else
  echo "`date` Invalid job count value $JOB_COUNT from $RES"
  exit 26
fi

echo "`date` $JOB_COUNT notifications required"

#
# Create a script to run each notification
for i in $NOTIFY_LIST
do
  #
  # Create a unique name from the job and sequence to be used
  # to create the threads shell command file.
  # this command file will be executed in background by the thread
  #
  THREAD_CMD=${EXE_DIR}/Notify${i}.sh
  THREAD_LOG=${LOG_DIR}/Notify${i}.log
  echo $THREAD_CMD
  #
  # Populate the thread shell command file
  # set default variables
  #
  echo "#!/bin/$RUNSHELL">$THREAD_CMD
  echo ". $ORAENV">>$THREAD_CMD
  echo "LOG_DIR=$LOG_DIR">>$THREAD_CMD
  echo "EXE_DIR=$EXE_DIR">>$THREAD_CMD
  #
  # Get the parameter for this notify
  #
  echo "PARAM=\`sqlplus -s <<WS010EOF3 | grep -v \"rows selected.$\" | grep -v \"^$\" | tr -d \"\\015\"">>$THREAD_CMD
  echo "\$DSS_USER/\$DSS_PWD">>$THREAD_CMD
  echo "set sqlprompt \"\";">>$THREAD_CMD
  echo "set heading off;">>$THREAD_CMD
  echo "set pagesize 0;">>$THREAD_CMD
  echo "set linesize 256;">>$THREAD_CMD
  echo "set trimspool on;">>$THREAD_CMD
  echo "set echo off;">>$THREAD_CMD
  echo "Select wmn_parameter from ws_wrk_mon_notify">>$THREAD_CMD
  echo "Where wmn_notify_number = $i;">>$THREAD_CMD
  echo "exit;">>$THREAD_CMD
  echo "WS010EOF3\`">>$THREAD_CMD
  #
  # Get the script key for this notify
  #
  echo "RES=\`sqlplus -s <<WS010EOF1 | grep -v \"completed\" | grep -v \"^$\" | tr -s \"\\012\" \"~\"">>$THREAD_CMD
  echo "$DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "set sqlprompt \"\";">>$THREAD_CMD
  echo "set heading off;">>$THREAD_CMD
  echo "set pagesize 0;">>$THREAD_CMD
  echo "set linesize 256;">>$THREAD_CMD
  echo "set trimspool on;">>$THREAD_CMD
  echo "set echo off;">>$THREAD_CMD
  echo "select wmn_script_key ">>$THREAD_CMD
  echo "from ws_wrk_mon_notify ">>$THREAD_CMD
  echo "where wmn_notify_number = $i;">>$THREAD_CMD
  echo "exit;">>$THREAD_CMD
  echo "WS010EOF1\`">>$THREAD_CMD
  #
  # Get the results from the sqlplus command and make
  # sure it worked else report an error and abort the thread
  #
  echo "#">>$THREAD_CMD
  echo "# See if we have a script to run">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "if [ \"\$?\" -ne \"0\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "   echo \"Sqlplus returned a non standard return code of \$?\"">>$THREAD_CMD
  echo "   echo \"\$RES\"">>$THREAD_CMD
  echo "   echo \"Aborting Job ....\"">>$THREAD_CMD
  echo "   exit 23">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  echo "RET_CHECK=\`echo \$RES | cut -d \" \" -f1\`">>$THREAD_CMD
  echo "if [ \"\$RET_CHECK\" = \"BEGIN\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "   echo \"Sqlplus failed with an oracle error. See logs\"">>$THREAD_CMD
  echo "   echo \"\$RES\"">>$THREAD_CMD
  echo "   echo \"Aborting Job....\"">>$THREAD_CMD
  echo "   exit -1">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  #
  # Sqlplus worked. So now get the script key
  #
  echo "echo \"Script key result: \$RES\"">>$THREAD_CMD
  echo "SCRIPT_KEY=\`echo \$RES | cut -d \"~\" -f1 | tr -d \" \"\`">>$THREAD_CMD
  #
  # Code below if a breakout script is required.
  # the script is loaded into the table ws_wrk_task_scr_line
  # and a header table exists providing information such as
  # the host platform etc.
  #
  #
  echo "if [ \"\$SCRIPT_KEY\" != \"\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  # Get the information from the script header file">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  #
  # Execute a sqlplus command to get information from the header
  # table about the script we are to run
  #
  echo "  RES=\`sqlplus -s <<WS010EOF2 | grep -v \"rows selected.$\" | grep -v \"^$\" | tr -d \"\\015\" | tr -s \"\\012\" \",\" ">>$THREAD_CMD
  echo "  \$DSS_USER/\$DSS_PWD">>$THREAD_CMD
  echo "  set sqlprompt \"\";">>$THREAD_CMD
  echo "  set heading off;">>$THREAD_CMD
  echo "  set pagesize 0;">>$THREAD_CMD
  echo "  set linesize 256;">>$THREAD_CMD
  echo "  set trimspool on;">>$THREAD_CMD
  echo "  set echo off;">>$THREAD_CMD
  echo "  Select sh_type ">>$THREAD_CMD
  echo "  From ws_scr_header ">>$THREAD_CMD
  echo "  Where sh_obj_key = \$SCRIPT_KEY;">>$THREAD_CMD
  echo "  exit;">>$THREAD_CMD
  echo "WS010EOF2\`">>$THREAD_CMD
  #
  # Get the script type from the header table
  # Check that this is a Unix script.
  # If not unix then unsupported.
  #
  echo "  #">>$THREAD_CMD
  echo "  # See what type of script we have">>$THREAD_CMD
  echo "  # If not a Unix script then not supported">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  echo \"Script type result: \$RES\"">>$THREAD_CMD
  echo "  HOST_TYPE=\`echo \$RES | cut -d \",\" -f1\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  #
  # Not Unix so not supported. We will process through the loop
  # again to pass the unsupported message back to the scheduler.
  #
  echo "  if [ \"\$HOST_TYPE\" != "U" ] && [ \"\$HOST_TYPE\" != "H" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    echo \"Unix monitor does not support Non Unix loads and scripts\"">>$THREAD_CMD
  echo "    THREAD_SH=\"\"">>$THREAD_CMD
  echo "    THREAD_BASE=\${EXE_DIR}/Notify${i}">>$THREAD_CMD
  echo "    THREAD_EXE=\"\${THREAD_BASE}_exec.sh\"">>$THREAD_CMD
  echo "    THREAD_AUD=\"\${THREAD_BASE}_script.aud\"">>$THREAD_CMD
  echo "    THREAD_ERR=\"\${THREAD_BASE}_script.err\"">>$THREAD_CMD
  echo "  else">>$THREAD_CMD
  #
  # Unix script so create the script, audit file and error file name
  #
  echo "    #">>$THREAD_CMD
  echo "    # create a name for our script, audit and error trail">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    THREAD_BASE=\${EXE_DIR}/Notify${i}">>$THREAD_CMD
  echo "    THREAD_SH=\"\${THREAD_BASE}_script.sh\"">>$THREAD_CMD
  echo "    THREAD_EXE=\"\${THREAD_BASE}_exec.sh\"">>$THREAD_CMD
  echo "    THREAD_AUD=\"\${THREAD_BASE}_script.aud\"">>$THREAD_CMD
  echo "    THREAD_ERR=\"\${THREAD_BASE}_script.err\"">>$THREAD_CMD
  echo "    # Get the actual script">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # Get the script itself into the script file
  # from the ws_scr_line table
  #
  echo "    sqlplus -s <<WS010EOF9 | grep -v \"rows selected.$\" | grep -v \"^$\" | tr -d \"\\015\" >\$THREAD_SH">>$THREAD_CMD
  echo "    \$DSS_USER/\$DSS_PWD">>$THREAD_CMD
  echo "    set sqlprompt \"\";">>$THREAD_CMD
  echo "    set heading off;">>$THREAD_CMD
  echo "    set pagesize 0;">>$THREAD_CMD
  echo "    set linesize 256;">>$THREAD_CMD
  echo "    set trimspool on;">>$THREAD_CMD
  echo "    set echo off;">>$THREAD_CMD
  echo "    Select sl_line from ws_scr_line">>$THREAD_CMD
  echo "    Where sl_obj_key = \$SCRIPT_KEY">>$THREAD_CMD
  echo "    Order by sl_line_no;">>$THREAD_CMD
  echo "    exit;">>$THREAD_CMD
  echo "WS010EOF9">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "# If no script then we will just use the parameter">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "else">>$THREAD_CMD
  echo "  THREAD_SH=\"\"">>$THREAD_CMD
  echo "  THREAD_BASE=\${EXE_DIR}/Notify${i}">>$THREAD_CMD
  echo "  THREAD_EXE=\"\${THREAD_BASE}_exec.sh\"">>$THREAD_CMD
  echo "  THREAD_AUD=\"\${THREAD_BASE}_script.aud\"">>$THREAD_CMD
  echo "  THREAD_ERR=\"\${THREAD_BASE}_script.err\"">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  #
  # Execute the script
  # The standard is that the first row on standard output is the result code
  # being either 1=success, -1=warning, -2=error, -3=fatal error
  # The second row on standard out will be the returned message
  #
  echo "echo \"Execute \$THREAD_EXE\"">>$THREAD_CMD
  echo "echo \"Script \$THREAD_SH\"">>$THREAD_CMD
  echo "echo \"Audit \$THREAD_AUD\"">>$THREAD_CMD
  echo "echo \"Error \$THREAD_ERR\"">>$THREAD_CMD
  echo "echo \"\$THREAD_SH \$PARAM\">\$THREAD_EXE">>$THREAD_CMD
  echo "if [ \"\$THREAD_SH\" != \"\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  chmod 750 \$THREAD_SH">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  echo "chmod 750 \$THREAD_EXE">>$THREAD_CMD
  echo "\$THREAD_EXE >\$THREAD_AUD 2>\$THREAD_ERR">>$THREAD_CMD
  echo "TASK_STATUS=\`head -1 \$THREAD_AUD | tr -d \" \"\`">>$THREAD_CMD
  echo "TASK_MSG=\`head -2 \$THREAD_AUD | tail -1\`">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "# Put out the result to the monitor log">>$THREAD_CMD
  echo "# And update the job to indicate taht we notified">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "if [ \"\$TASK_STATUS\" = \"1\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  TASK_RESULT=\"S\"">>$THREAD_CMD
  echo "else">>$THREAD_CMD
  echo "  TASK_RESULT=\"E\"">>$THREAD_CMD
  echo "fi ">>$THREAD_CMD
  echo "if [ \"\$TASK_MSG\" = \"\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  TASK_MSG=\"Notification script returned no result. Unknown if notify worked\"">>$THREAD_CMD
  echo "fi ">>$THREAD_CMD
  echo "sqlplus -s <<WS010EOF6">>$THREAD_CMD
  echo "  $DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "  INSERT INTO ws_wrk_mon_log (wml_job_key, wml_job_name, ">>$THREAD_CMD
  echo "    wml_time_stamp, wml_status, wml_message, wml_notify_ind)">>$THREAD_CMD
  echo "  SELECT wmn_job_key, wmn_job_name, sysdate, ">>$THREAD_CMD
  echo "  '\$TASK_RESULT','\$TASK_MSG','N' ">>$THREAD_CMD
  echo "  FROM ws_wrk_mon_notify WHERE wmn_notify_number = $i;">>$THREAD_CMD
  echo "  UPDATE ws_wrk_mon_job ">>$THREAD_CMD
  echo "  SET wmj_last_notify_type = (SELECT wmn_notify_type FROM ws_wrk_mon_notify ">>$THREAD_CMD
  echo "     WHERE wmn_notify_number = $i)">>$THREAD_CMD
  echo "  , wmj_last_notify_date = sysdate ">>$THREAD_CMD
  echo "  WHERE wmj_job_key = (SELECT wmn_job_key FROM ws_wrk_mon_notify ">>$THREAD_CMD
  echo "    WHERE wmn_notify_number = $i);">>$THREAD_CMD
  echo "exit;">>$THREAD_CMD
  echo "WS010EOF6">>$THREAD_CMD
  #
  # If there are any additional rows in standard out then write then to
  # the audit trail
  #
  echo "LIN=\`cat \$THREAD_AUD | wc -l | tr -d \" \"\`">>$THREAD_CMD
  echo "echo \"\$LIN audit lines\"">>$THREAD_CMD
  echo "if [ \"\$LIN\" != \"2\" ] ">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  ROWNUM=0">>$THREAD_CMD
  echo "  while [ \"\$ROWNUM\" -lt \"\$LIN\" ]">>$THREAD_CMD
  echo "  do">>$THREAD_CMD
  echo "    let ROWNUM=\"\$ROWNUM+1\"">>$THREAD_CMD
  echo "    if [ \"\$ROWNUM\" -gt \"2\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      AUD_TRAIL=\`cat \$THREAD_AUD |head -\$ROWNUM | tail -1| sed \"s/'/''/g\"\`">>$THREAD_CMD
  echo "      sqlplus -s <<WS010EOF4">>$THREAD_CMD
  echo "      $DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "      INSERT INTO ws_wrk_mon_log (wml_job_key, wml_job_name, ">>$THREAD_CMD
  echo "       wml_time_stamp, wml_status, wml_message, wml_notify_ind)">>$THREAD_CMD
  echo "        SELECT wmn_job_key, wmn_job_name, sysdate,'I','\$AUD_TRAIL','N'">>$THREAD_CMD
  echo "      FROM ws_wrk_mon_notify WHERE wmn_notify_number = $i;">>$THREAD_CMD
  echo "     exit;">>$THREAD_CMD
  echo "WS010EOF4">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "  done">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  #
  # If any rows in standard error then write them to the error/detail trail
  #
  echo "LIN=\`cat \$THREAD_ERR | wc -l | tr -d \" \"\`">>$THREAD_CMD
  echo "echo \"\$LIN error trail lines\"">>$THREAD_CMD
  echo "if [ \"\$LIN\" != \"0\" ] ">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  ROWNUM=0">>$THREAD_CMD
  echo "  while [ \"\$ROWNUM\" -lt \"\$LIN\" ]">>$THREAD_CMD
  echo "  do">>$THREAD_CMD
  echo "    let ROWNUM=\"\$ROWNUM+1\"">>$THREAD_CMD
  echo "    ERR_TRAIL=\`cat \$THREAD_ERR | head -\$ROWNUM | tail -1 | sed \"s/'/''/g\"\`">>$THREAD_CMD
  echo "    sqlplus -s <<WS010EOF5">>$THREAD_CMD
  echo "    $DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "      INSERT INTO ws_wrk_mon_log (wml_job_key, wml_job_name, ">>$THREAD_CMD
  echo "        wml_time_stamp, wml_status, wml_message, wml_notify_ind)">>$THREAD_CMD
  echo "        SELECT wmn_job_key, wmn_job_name, sysdate,'I','\$ERR_TRAIL','N'">>$THREAD_CMD
  echo "        FROM ws_wrk_mon_notify WHERE wmn_notify_number = $i;">>$THREAD_CMD
  echo "     exit;">>$THREAD_CMD
  echo "WS010EOF5">>$THREAD_CMD
  echo "  done">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  #
  #
  # Finished the create of the script the thread will run
  # so set it to an executable and
  # Run it in background
  #
  chmod 750 $THREAD_CMD
  nohup $THREAD_CMD >$THREAD_LOG 2>&1 &
done
exit


