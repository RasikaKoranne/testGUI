#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# Script Name       : ws_job_wait_600.sh
# Description       : Initiates the threads of a job that is ready
# Author            : WhereScape
# Date              : 12/02/2002
# WhereScape Limited, inc. All rights reserved. (C) Copyright 2002-2019
# =============================================================================
# Notes / History
#
# Positional parameters are 1 = dbenv file name, 2 = scheduler name
#
# WMR 25/02/2002  Version 1.0.1   Changed method of recording audit and error messages due
#                                  to problems on IBM platform. Now 1 line at a time
# WMR 01/03/2002                  Added additional debug messages when a failure occurs
# WMR 05/04/2002  Version 1.0.7   Scheduler selection support
# WMR 05/04/2002  Version 1.0.7.1 Produce failure if ODBC jobs attempted
# WMR 12/10/2002  Version 1.2.1.3 Changed EOF to WSL010EOF to avoid conflict
#                                  with user written scripts
# WMR 22/04/2003  Version 1.2.1.7 Handle single quotes in result message
#                                 and ensure numeric task status
# WMR 15/08/2003  Version 4.1.0   Put variables in oraenv.
# WMR 28/11/2003  Changed job name to WSLnnnn_xx_job, nnn=sequence, xx=thread
# WMR 01/09/2004  Version 4.1.0.7 Put job name, task_name, job_key, task_key, seq
#                                  in as positional parameters in the executed script
# WMR 01/03/2005  Version 4.1.1.3 Now call Ws_Job_Exec_411 to handle jobs within jobs
# JML 17/04/2007  Version 5.6.0.0 Added support for export objects
# WMR 03/07/2008  Version 6.0.0.0 DB2 support added
# AP  16/07/2008  Version 6.0.0.2 Added SLEEP processing
# WMR 30/07/2008  Version 6.0.0.3 Added support for either trusted or password
# JML 02/09/2008  Version 6.0.2.0 Teradata
# JML 01/04/2009  Version 6.0.4.0 Added DSS_METADATA. where missing.
# WMR 31/05/2012  Version 6.6.1.1 Error log records now handled correctly
# RS  26/07/2012  Version 6.6.2.1 Added ".exit" to BTEQ calls
# RS  27/07/2012  Version 6.6.2.1 Added capture of BTEQ warnings and errors into log-file
# RS  07/03/2014  Version 6.7.4.0 Bug fixed for multi-threading
# RS  03/06/2014  Version 6.8.0.1 Added dynamic read of ODBC source connection information
# AP  04/07/2014  Version 6.8.0.2 Fix for when schedule a script directly
# AP  07/07/2014  Version 6.8.0.2 Use wallet for TPT load if exists as default RED_3830
# BC  08/05/2015  Version 6.8.3.4 Added support for Hadoop scripts
# RS  19/05/2015  Version 6.8.3.4 Fixed escape string for usage of wallet
# BC  10/02/2016  Version 6.8.5.3 Added support for BDA Server operations
# RS  24/02/2016  Version 6.8.5.3 Extended width to 8000 in BTEQ to cater for long outputs in rejoin with BDA
# TA  25/02/2016  Version 6.8.5.3 Added support for BDA Server authentication
# RS  21/03/2016  Version 6.8.5.3 Added error handling for remote objects
# BC  30/03/2016  Version 6.8.5.4 RED-881 Support added to execute Failure Command when job
#                                  fails due to job dependency failure.
# AP  09/06/2016  Version 6.8.6.1 RED-6876 Added error handling for invalid procedure calls
# RS  16/06/2016  Version 6.8.6.1 RED-6876 Fixed issue with reporting of asterisks
# RS  27/06/2016  Version 6.8.6.1 RED-6770 Added check for additional TPT ODBC source in source connection
# HM  14/11/2016  Version 6.8.6.3 RED-6610 Added BTEQ Update procedure support
# BC  16/11/2016  Version 6.8.6.3 RED-7329 Initialise new environment variables for Script-based loads and exports.
# BC  27/01/2017  Version 6.8.7.0 RED-7740 Initialise new environment variables for standalone Script executions.
# TA  23/11/2018  Version 8.3.1.0 RED-9957 Support arbitrary script interpreters
# HM  01/03/2019  Version 8.3.1.1 RED-10221 Ensure primary index is used when updating ws_wrk_task_run log counts to prevent deadlock.
#
# ============================================================================
# SETTINGS
#
TDENV=$HOME/$1
RUNSHELL=sh
# ============================================================================
. $TDENV
#
# Note: acquire the job exe directory from the tdenv file if set.
if [ "$JOB_EXE_DIR" = "" ]
then
  EXE_DIR=$HOME/wsl/sched/job
else
  EXE_DIR=$JOB_EXE_DIR
fi
#
# Note: acquire the job log directory from the tdenv file if set.
if [ "$JOB_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/sched/joblog
else
  LOG_DIR=$JOB_LOG_DIR
fi
##
# Issue the job wait procedure to see if any jobs waiting to run
##
RES1=`bteq <<WSL600EOF 2>&1
.logon ${DSS_BTEQDB}/${DSS_USER},${DSS_PWD}
.set width 254
.set foldline on 1,2,3,4,5,6
CALL $DSS_METABASE.WS_JOB_WAIT('UNIX','$2',?,?,?,?,?,?);
.exit
WSL600EOF`
RES2=$?

##
# Check for  warning text as BTEQ exits with 0
##

BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`

if [ "$RES2" -ne "0" -o "$BTEQ_WARNING" != "" ]
then
  if [ "$RES2" -eq "4" -o "$BTEQ_WARNING" != "" ]
  then
    echo "Failure when issuing the ws_job_wait procedure. A SQL error occurred"
  else
    echo "Failure when issuing the Ws_Job_Wait procedure. Return code from BTEQ of $RES2"
  fi
  echo "$RES1"
  echo "$RES2"
  echo "Aborting Scheduler...."
  exit 23
fi
##
# Get the line number of output and work out the RET_CODE
##
LINE=`echo "$RES1" | grep -n "p_job_name" | cut -d: -f1`
let LINE="$LINE + 17"
RET_CODE=`echo "$RES1" | head -$LINE | tail -1 | tr -d " "`
#DEBUG echo LINE=$LINE
#DEBUG echo RES1="$RES1"
#DEBUG echo RET_CODE=$RET_CODE
#
# Get the return status
# If a negative then we have a problem
# If 2 then no jobs so quit.
# if 5 then asked to do a status
# if 9 then asked to shutdown
#
if [ "$RET_CODE" = "2" ]
then
  exit 2
elif [ "$RET_CODE" = "5" ]
then
  exit 5
elif [ "$RET_CODE" = "9" ]
then
  exit 9
elif [ "$RET_CODE" == "-98" ]
then
  JOB_NAME=`echo "$RES1" | head -$LINE | tail -6 | head -1`
  JOB_SEQ=`echo "$RES1" | head -$LINE | tail -2 | head -1 | tr -d ' '`
  JOB_THREAD=0
  echo Job dependency failure for $JOB_NAME $JOB_SEQ
  RES1=`bteq <<WSL600EOF 2>&1
    .logon ${DSS_BTEQDB}/${DSS_USER},${DSS_PWD}
    .set echoreq off
    .set width 254
    .set foldline on 1,2,3
    SELECT 'WSLDELIM' || wjr_job_key AS job_key, 'WSLDELIM' || wjr_publish_fail AS fail_cmd, 'WSLDELIM' AS rec_delim FROM $DSS_METABASE.ws_wrk_job_run WHERE TRIM(TRAILING FROM UPPER(wjr_name)) = TRIM(TRAILING FROM UPPER('$JOB_NAME'));
    .exit
WSL600EOF`
  RES2=$?
  RES=`echo $RES1 | sed "s/~/WSLTILDE/g" | sed "s/WSLDELIM/~/g"`
  JOB_KEY=`echo $RES | cut -d "~" -f2 | tr -d " "`
  ACT_MSG=`echo $RES | cut -d "~" -f3 | sed "s/WSLTILDE/~/g" | sed "s/[$]JOB_NAME[$]/$JOB_NAME/g" | sed "s/[$]JOB_KEY[$]/$JOB_KEY/g" | sed "s/[$]JOB_SEQ[$]/$JOB_SEQ/g" | sed "s/[$]JOB_THREAD[$]/$JOB_THREAD/g" | sed "s/'/''/g"`
  RES1=`bteq <<WSL600EOF 2>&1
    .logon ${DSS_BTEQDB}/${DSS_USER},${DSS_PWD}
    .set echoreq off
    .set width 254
    .set foldline on 1
    CALL $DSS_METABASE.WsParameterReplace('$ACT_MSG',4000,?);
    .exit
WSL600EOF`
  RES2=$?
  LINE=`echo "$RES1" | grep -n "p_return_value" | cut -d: -f1`
  let LINE="$LINE + 2"
  ACT_MSG=`echo "$RES1" | head -$LINE | tail -1`
  if [ "$ACT_MSG" != "" ]
  then
    echo Result action for FAILURE is $ACT_MSG
    sh -c "$ACT_MSG"
    if [ "$?" != "0" ]
    then
      echo FAILURE action failed $ACT_MSG
    fi
  fi
  exit 2
elif [ "$RET_CODE" != "1" ]
then
  echo "Failed with return code $RET_CODE"
  echo "$RES1"
  echo "$RES2"
  exit 25
fi
#
# Set up all our parameter variables
#
JOB=`echo "$RES1" | head -$LINE | tail -6 | head -1`
TASK=`echo "$RES1" | head -$LINE | tail -5 | head -1 | tr -d ' '`
FLAG=`echo "$RES1" | head -$LINE | tail -4 | head -1 | tr -d ' '`
THREADS=`echo "$RES1" | head -$LINE | tail -3 | head -1 | tr -d ' '`
SEQ=`echo "$RES1" | head -$LINE | tail -2 | head -1 | tr -d ' '`
#DEBUG echo JOB=$JOB
#DEBUG echo TASK=$TASK
#DEBUG echo FLAG=$FLAG
#DEBUG echo THREADS=$THREADS
#DEBUG echo SEQ=$SEQ
#
# check that thread count is between 1 and 9
# if not then abort
#
nJob=0
THREAD_LIST=""
if [ "$THREADS" -gt "0"  -a  "$THREADS" -le "50" ]
then
  while [ $THREADS -gt 0 ]
  do
    THREAD_LIST="$THREAD_LIST $nJob"
    let nJob="$nJob+1"
    let THREADS="$THREADS-1"
  done
  echo $THREAD_LIST
  echo "$nJob Threads"
else
  echo "Invalid thread value $THREADS"
  exit 26
fi
# echo "-$JOB-$TASK-$FLAG-$THREADS-$SEQ-"
JOBFILE=`echo $JOB | tr -s ' ' '_' | tr -s '\t' '_'`
#DEBUG echo JOBFILE=$JOBFILE
#
# Create a script to run each thread of the job
# Need to look at a job shell file to understand this output
#
date
for i in $THREAD_LIST
do
  #
  # Create a unique name from the job and sequence to be used
  # to create the threads shell command file.
  # this command file will be executed in background by the thread
  #
  echo  $JOB $TASK $FLAG $THREADS $SEQ
  THREAD_CMD=${EXE_DIR}/WSL${SEQ}_${i}_${JOBFILE}
  THREAD_LOG=${LOG_DIR}/WSL${SEQ}_${i}_${JOBFILE}.log
  FILEAUD=${LOG_DIR}/WSL${SEQ}_${i}_${JOBFILE}.aud

  echo $THREAD_CMD
  #
  # Populate the thread shell command file
  # set default variables
  #
  echo "#!/bin/$RUNSHELL">$THREAD_CMD
  echo ". $HOME/$1">>$THREAD_CMD
  echo "JOB_NAME=\"$JOB\"">>$THREAD_CMD
  echo "JOB_NAME=\`echo \$JOB_NAME\`">>$THREAD_CMD
  echo "MASTER_JOB_NAME=\"$JOB\"">>$THREAD_CMD
  echo "TASK_NAME=\"$TASK\"">>$THREAD_CMD
  echo "TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "ACTION=\"$FLAG\"">>$THREAD_CMD
  echo "THREAD=$i; export THREAD">>$THREAD_CMD
  echo "SEQ=$SEQ; export SEQ">>$THREAD_CMD
  echo "JOB_KEY=0">>$THREAD_CMD
  echo "MASTER_JOB_KEY=0">>$THREAD_CMD
  echo "TASK_KEY=0">>$THREAD_CMD
  echo "TASK_STATUS=0">>$THREAD_CMD
  echo "TASK_MSG=\"\"">>$THREAD_CMD
  echo "LOG_DIR=$LOG_DIR">>$THREAD_CMD
  echo "EXE_DIR=$EXE_DIR">>$THREAD_CMD
  echo "REJOIN_JOB_LIST=\"\"">>$THREAD_CMD
  echo "REJOIN_TASK_LIST=\"\"">>$THREAD_CMD
  # RED_3538
  echo "FILEAUD=${LOG_DIR}/WSL${SEQ}_${i}_${JOBFILE}.aud">>$THREAD_CMD
  #
  # If not thread 0 then loop until job exists
  #   Thread 0 starts the job
  #
  if [ "$i" = "0" ]
  then
    echo "bMORE=\"Y\"">>$THREAD_CMD
  else
    echo "bMORE=\"N\"">>$THREAD_CMD
    #
    # Loop until job in run state or exceed wait time
    #
    echo "nCheck=0">>$THREAD_CMD
    echo "nCheckMax=12">>$THREAD_CMD
    # for restart jobs loop 30 times; default is 12 times
    echo "if [ \"\$ACTION\" = \"RESTART\" ]">>$THREAD_CMD
    echo "then">>$THREAD_CMD
    echo "  nCheckMax=30">>$THREAD_CMD
    echo "fi">>$THREAD_CMD
    #
    echo "while [ \"\$bMORE\" = \"N\" ] && [ \"\$nCheck\" -le \"\$nCheckMax\" ]">>$THREAD_CMD
    echo "do">>$THREAD_CMD
    #DEBUG  echo "  echo \"Waiting count :\$nCheck \"">>$THREAD_CMD
    echo "  sleep 10">>$THREAD_CMD
    echo "  let nCheck=\"\$nCheck + 1\"">>$THREAD_CMD
    #
    # Execute a Teradata command to see if the job is running yet
    #
    # RED_3538
    echo "  RES1=\`bteq <<WSL600SEOFS 2>> \${FILEAUD}">>$THREAD_CMD
    echo "  .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
    echo "  Select '~',wjr_job_key,'~' ">>$THREAD_CMD
    echo "  From $DSS_METABASE.ws_wrk_job_run ">>$THREAD_CMD
    echo "  Where trim(upper(wjr_name)) = trim(upper('\$JOB_NAME')) ">>$THREAD_CMD
    echo "  And wjr_sequence = \$SEQ ">>$THREAD_CMD
    echo "  And wjr_status = 'R'; ">>$THREAD_CMD
    echo "  .exit ">>$THREAD_CMD
    echo "WSL600SEOFS\`">>$THREAD_CMD
    #
    echo "  RES2=\$?" >>$THREAD_CMD
    #
    # Get the results from the command and make
    # sure it worked else report an error and abort the thread
    #
    echo "  if [ \"\$RES2\" -ne \"0\" ] && [ \"\$RES2\" -ne \"1\" ] ">>$THREAD_CMD
    echo "  then">>$THREAD_CMD
    echo "     echo \"Teradata returned a non standard return code from the BTEQ of \$RES2\"">>$THREAD_CMD
    echo "     echo \"\$RES1\"">>$THREAD_CMD
    echo "     echo \"Aborting Job ....\"">>$THREAD_CMD
    echo "     exit 23">>$THREAD_CMD
    echo "  fi">>$THREAD_CMD

     # Check warnings in the BTEQ command with exit 0
    echo "    ##" >>$THREAD_CMD
    echo "    # Check for  warning text as BTEQ exits with 0" >>$THREAD_CMD
    echo "    ##" >>$THREAD_CMD
    echo "  BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`" >>$THREAD_CMD
     echo "  if [ \"\$BTEQ_WARNING\" \!\= \"\" ] ">>$THREAD_CMD
    echo "  then">>$THREAD_CMD
    echo "     echo \"Teradata returned with warnings from the BTEQ of \$RES2\"">>$THREAD_CMD
    echo "     echo \"\$RES1\"">>$THREAD_CMD
    echo "     echo \"Continuing Job ....\"">>$THREAD_CMD
    echo "  fi">>$THREAD_CMD

    #
    echo "RES=\`echo \"\$RES1\" | sed \"s/ ~ /~/g\"\`">>$THREAD_CMD
    #
    echo "  #">>$THREAD_CMD
    echo "  # See if the Job has started">>$THREAD_CMD
    echo "  #">>$THREAD_CMD
    echo "  JOB_KEY=\`echo \$RES | cut -d \"~\" -f6\`">>$THREAD_CMD
    echo "  #">>$THREAD_CMD
    echo "  if [ \"\$JOB_KEY\" -ne \"0\" ]">>$THREAD_CMD
    echo "  then">>$THREAD_CMD
    #DEBUG echo "    echo \"job_key: \$JOB_KEY \"">>$THREAD_CMD
    echo "    bMORE=\"Y\"">>$THREAD_CMD
    echo "  fi">>$THREAD_CMD
    echo "done">>$THREAD_CMD
    #
  fi
  #
  # Loop through execution of the ws_job_exec_nnn procedure
  # re-entering the procedure after each Unix shell script
  # has been handled.
  # When all breakout scripts have been finished or if we have
  # none or we fail then the loop will be terminated
  #
  echo "while [ \"\$bMORE\" = \"Y\" ]">>$THREAD_CMD
  echo "do">>$THREAD_CMD
  #
  # Execute a Teradata command to get the job level username and password
  #
  echo "  RES1=\`bteq <<WSL600JEOF1 2>&1">>$THREAD_CMD
  echo "  .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "  .set width 254">>$THREAD_CMD
  echo "  Select '~',COALESCE(wjr_run_userid,''),'~',COALESCE(wjr_run_pwd,''),'~' ">>$THREAD_CMD
  echo "  From $DSS_METABASE.ws_wrk_job_run ">>$THREAD_CMD
  echo "  Where trim(upper(wjr_name)) = trim(upper('\$JOB_NAME')); ">>$THREAD_CMD
  echo "  .exit ">>$THREAD_CMD
  echo "WSL600JEOF1\`">>$THREAD_CMD
  #
  echo "  RES2=\$?" >>$THREAD_CMD
  #
  # Get the results from the command and make
  # sure it worked else report an error and abort the thread
  #
  echo "  if [ \"\$RES2\" -ne \"0\" ] && [ \"\$RES2\" -ne \"1\" ] ">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "     echo \"Teradata returned a non standard return code from the BTEQ of \$RES2\"">>$THREAD_CMD
  echo "     echo \"\$RES1\"">>$THREAD_CMD
  echo "     echo \"Aborting Job ....\"">>$THREAD_CMD
  echo "     exit 23">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD

  # Check warnings in the BTEQ command with exit 0
  echo "    ##" >>$THREAD_CMD
  echo "    # Check for  warning text as BTEQ exits with 0" >>$THREAD_CMD
  echo "    ##" >>$THREAD_CMD
  echo "  BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`" >>$THREAD_CMD
  echo "  if [ \"\$BTEQ_WARNING\" \!\= \"\" ] ">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "     echo \"Teradata returned with warnings from the BTEQ of \$RES2\"">>$THREAD_CMD
  echo "     echo \"\$RES1\"">>$THREAD_CMD
  echo "     echo \"Continuing Job ....\"">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD

  #
  echo "  RES=\`echo \"\$RES1\" | sed \"s/ ~ /~/g\"\`">>$THREAD_CMD
  #
  echo "  #">>$THREAD_CMD
  echo "  # Set the User and Password for running tasks.">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  JOB_USER=\`echo \$RES | cut -d \"~\" -f8 | tr -d \" \"\`">>$THREAD_CMD
  echo "  JOB_PWD=\`echo \$RES | cut -d \"~\" -f9 | tr -d \" \"\`">>$THREAD_CMD
  echo "  if [ -z \"\$JOB_USER\" ] || [ -z \"\$JOB_PWD\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    JUSER=\$DSS_USER; export JUSER">>$THREAD_CMD
  echo "    JPWD=\$DSS_PWD; export JPWD">>$THREAD_CMD
  echo "  else">>$THREAD_CMD
  echo "    JUSER=\$JOB_USER; export JUSER">>$THREAD_CMD
  echo "    JPWD=\$JOB_PWD; export JPWD">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD
  #
  # Execute the ws-job_exec_nnn procedure.
  #
  echo "  TASK_MSG=\`echo \"\$TASK_MSG\" | sed \"s/'/''/g\"\`">>$THREAD_CMD
  #
  #DEBUG echo "  echo \"CALL $DSS_METABASE.WS_JOB_EXEC_411('\$JOB_NAME','\$TASK_NAME','\$ACTION',\"">>$THREAD_CMD
  #DEBUG echo "  echo \"\$THREAD,\$SEQ,\$JOB_KEY,\$TASK_KEY,\$TASK_STATUS,'\$TASK_MSG',\"">>$THREAD_CMD
  #DEBUG echo "  echo \"'\$REJOIN_JOB_LIST','\$REJOIN_TASK_LIST', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)\"">>$THREAD_CMD
  #
  echo "  RES1=\`bteq <<WSL600EOF1 2>&1">>$THREAD_CMD
  echo "  .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "  .set width 8000">>$THREAD_CMD
  echo "  .set foldline on 1,2,3,4,5,6,7,8,9,10">>$THREAD_CMD
  echo "  CALL $DSS_METABASE.WS_JOB_EXEC_411('\$JOB_NAME','\$TASK_NAME','\$ACTION', ">>$THREAD_CMD
  echo "  \$THREAD,\$SEQ,\$JOB_KEY,\$TASK_KEY,\$TASK_STATUS,'\$TASK_MSG', ">>$THREAD_CMD
  echo "  '\$REJOIN_JOB_LIST','\$REJOIN_TASK_LIST', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?); ">>$THREAD_CMD
  echo "  .exit ">>$THREAD_CMD
  echo "WSL600EOF1\`">>$THREAD_CMD
  #
  # Get the results from the command and make
  # sure it worked else report an error and abort the thread
  #
  echo "  #">>$THREAD_CMD
  echo "  # Set up all our parameter variables">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  RES2=\$?" >>$THREAD_CMD
  #DEBUG echo "echo \"RES1 =  \$RES1\"">>$THREAD_CMD
  echo "  if [ \"\$RES2\" -ne \"0\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "     echo \"Teradata returned a non standard return code from the BTEQ of \$RES2\"">>$THREAD_CMD
  echo "     echo \"\$RES1\"">>$THREAD_CMD
  echo "     echo \"Aborting Job ....\"">>$THREAD_CMD
  echo "     exit 23">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD

  # Check warnings in the BTEQ command with exit 0
  echo "    ##" >>$THREAD_CMD
  echo "    # Check for  warning text as BTEQ exits with 0" >>$THREAD_CMD
  echo "    ##" >>$THREAD_CMD
  echo "  BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`" >>$THREAD_CMD
  echo "  if [ \"\$BTEQ_WARNING\" \!\= \"\" ] ">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "     echo \"Teradata returned with warnings from the BTEQ of \$RES2\"">>$THREAD_CMD
  echo "     echo \"\$RES1\"">>$THREAD_CMD
  echo "     echo \"Continuing Job ....\"">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD

  echo "  LINE=\`echo \"\$RES1\" | grep -n \"po_result_code\" | cut -d: -f1\`">>$THREAD_CMD
  echo "  let LINE=\"\$LINE + 29\"">>$THREAD_CMD
  echo "  RET_CODE=\`echo \"\$RES1\" | head -\$LINE | tail -10 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  #
  # command worked. So now we need to see if the job worked, failed
  # or wishes to run a breakout script
  #
  echo "  # Get the return status">>$THREAD_CMD
  echo "  # If a negative then we have a job warning, error or failure">>$THREAD_CMD
  echo "  # If 2 then a script to run.">>$THREAD_CMD
  echo "  # If 1 then all okay">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  #
  echo "  if [ \"\$RET_CODE\" = "1" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  #
  # Code below if we have finished and it was successful
  #
  echo "    echo \"Normal Completion\"">>$THREAD_CMD
  echo "    bMORE=\"N\"">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  #DEBUG echo "echo \"ACTION_KEY  =  \$ACTION_KEY\"">>$THREAD_CMD
  #DEBUG echo "echo \"ACTION_MSG  =  \$ACTION_MSG\"">>$THREAD_CMD
  echo "  elif [ \"\$RET_CODE\" = \"2\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  #
  # Code below if a breakout script is required.
  # the script is loaded into the table ws_wrk_task_scr_line
  # and a header table exists providing information such as
  # the host platform etc.
  #
  # Get the information returned from ws_job_exec_nnn which is
  # the job and task keys
  #
  echo "    echo \"Script Called\"">>$THREAD_CMD
  echo "    RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "    REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    # Break out the returned variables">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    # Get the information from the script header file">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # Execute a Teradata command to get information from the header
  # table about the script we are to run
  #
  #
  # RED_3494
  # Get the ODBC source connection info for TPT ODBC script loads
  # from the object key
  #
  echo "    RES1=\`bteq <<WSL600EOF2 2>&1">>$THREAD_CMD
  echo "    .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "    .set width 254">>$THREAD_CMD
  echo "    Select '~'||'~'||COALESCE(wtsh_host_type,'')||'~'|| ">>$THREAD_CMD
  echo "         COALESCE(wtsh_work_dir,'')||'~'|| ">>$THREAD_CMD
  echo "         COALESCE(wtsh_script_type,'')||'~'|| ">>$THREAD_CMD
  echo "         COALESCE(wtsh_load_type,'')||'~'|| ">>$THREAD_CMD
  echo "         CAST(COALESCE(wtsh_script_key,0) AS VARCHAR(18))||'~'|| ">>$THREAD_CMD
  echo "         CAST(COALESCE(wtsh_load_key,0) AS VARCHAR(18))||'~'|| ">>$THREAD_CMD
  echo "         CAST(COALESCE(wtsh_connect_key,0) AS VARCHAR(18))||'~'||  ">>$THREAD_CMD
  # If we have an extra TPT ODBC source defined use this one, else use the ODBC source defined in the connection
  echo "         CASE WHEN src.dc_attributes like '%TptODBCSource~=%' ">>$THREAD_CMD
  echo "         THEN  ">>$THREAD_CMD
  echo "           REGEXP_REPLACE( ">>$THREAD_CMD
  echo "             REGEXP_REPLACE(SUBSTR(src.dc_attributes,POSITION('TptODBCSource~=' IN src.dc_attributes) + CHARACTER_LENGTH('TptODBCSource~='),CHARACTER_LENGTH(src.dc_attributes)), ">>$THREAD_CMD
  echo "             '[0-9]+;','', 1), ">>$THREAD_CMD
  echo "             ';[\x20-\x7E]*','',1) ">>$THREAD_CMD
  echo "         ELSE ">>$THREAD_CMD
  echo "           COALESCE(src.dc_odbc_source,'') ">>$THREAD_CMD
  echo "         END ||'~'|| ">>$THREAD_CMD
  # RED_3830 echo "         CASE WHEN src.dc_authentication like '%DefODBCUser~= 2%'" >>$THREAD_CMD
  # echo "                      THEN  SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "                 THEN SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "                                                                                                                                          CHARACTER_LENGTH(src.dc_authentication)),';')," >>$THREAD_CMD
  echo "                                                         CASE WHEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') > 0" >>$THREAD_CMD
  echo "                                                              THEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') - 1" >>$THREAD_CMD
  echo "                                                              ELSE CHARACTER_LENGTH(src.dc_authentication)" >>$THREAD_CMD
  echo "                                                         END)" >>$THREAD_CMD
  # RED_3830 echo "                      ELSE src.dc_extract_userid " >>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END ||'~'|| " >>$THREAD_CMD
  echo "                      src.dc_extract_userid ||'~'||" >>$THREAD_CMD
  # RED_3830 echo "         CASE WHEN src.dc_authentication like '%DefODBCUser~= 2%'">>$THREAD_CMD
  # echo "                      THEN  'tdwallet(' ||  SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "               THEN SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "                                                                                                                                          CHARACTER_LENGTH(src.dc_authentication)),';'),">>$THREAD_CMD
  echo "                                                         CASE WHEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') > 0">>$THREAD_CMD
  echo "                                                              THEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') - 1">>$THREAD_CMD
  echo "                                                              ELSE CHARACTER_LENGTH(src.dc_authentication)">>$THREAD_CMD
  echo "                                                         END)">>$THREAD_CMD
  # RED_3830 echo "                      ELSE   src.dc_extract_pwd">>$THREAD_CMD
  # echo "                 END ||'~' DATA_STREAM ">>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END ||'~'|| " >>$THREAD_CMD
  echo "                      src.dc_extract_pwd ||'~'||" >>$THREAD_CMD
  # RED_3830 echo "         CASE WHEN tgt.dc_authentication like '%DefODBCUser~= 2%'" >>$THREAD_CMD
  # echo "                      THEN  SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "         CASE WHEN tgt.dc_authentication like '%TDWalletUser~=%' AND tgt.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "                 THEN SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "                                                                                                                                          CHARACTER_LENGTH(tgt.dc_authentication)),';')," >>$THREAD_CMD
  echo "                                                         CASE WHEN INDEX( SUBSTR(tgt.dc_authentication,  INDEX(tgt.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(tgt.dc_authentication)),';'), 100),';') > 0" >>$THREAD_CMD
  echo "                                                              THEN INDEX( SUBSTR(tgt.dc_authentication,  INDEX(tgt.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(tgt.dc_authentication)),';'), 100),';') - 1" >>$THREAD_CMD
  echo "                                                              ELSE CHARACTER_LENGTH(tgt.dc_authentication)" >>$THREAD_CMD
  echo "                                                         END)" >>$THREAD_CMD
  # RED_3830 echo "                      ELSE tgt.dc_extract_userid " >>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END ||'~'|| " >>$THREAD_CMD
  echo "                      tgt.dc_extract_userid ||'~'||" >>$THREAD_CMD
  # RED_3830 echo "         CASE WHEN tgt.dc_authentication like '%DefODBCUser~= 2%'">>$THREAD_CMD
  # echo "                      THEN  'tdwallet(' ||  SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "         CASE WHEN tgt.dc_authentication like '%TDWalletUser~=%' AND tgt.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "               THEN SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "                                                                                                                                          CHARACTER_LENGTH(tgt.dc_authentication)),';'),">>$THREAD_CMD
  echo "                                                         CASE WHEN INDEX( SUBSTR(tgt.dc_authentication,  INDEX(tgt.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(tgt.dc_authentication)),';'), 100),';') > 0">>$THREAD_CMD
  echo "                                                              THEN INDEX( SUBSTR(tgt.dc_authentication,  INDEX(tgt.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(tgt.dc_authentication, INDEX(tgt.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(tgt.dc_authentication)),';'), 100),';') - 1">>$THREAD_CMD
  echo "                                                              ELSE CHARACTER_LENGTH(tgt.dc_authentication)">>$THREAD_CMD
  echo "                                                         END)">>$THREAD_CMD
  # RED_3830 echo "                      ELSE   tgt.dc_extract_pwd">>$THREAD_CMD
  # echo "                 END ||'~' DATA_STREAM ">>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END ||'~'|| " >>$THREAD_CMD
  echo "                      tgt.dc_extract_pwd ||'~' DATA_STREAM " >>$THREAD_CMD
  echo "    From $DSS_METABASE.ws_wrk_task_scr_hdr ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_load_tab on lt_obj_key = wtsh_load_key ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_dbc_connect src ON src.dc_obj_key = (CASE WHEN lt_obj_key IS NOT NULL THEN lt_connect_key ELSE wtsh_connect_key END) ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_obj_object ON lt_obj_key = oo_obj_key ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_dbc_target ON oo_target_key = dt_target_key ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_dbc_connect tgt ">>$THREAD_CMD
  echo "      ON (lt_obj_key IS NOT NULL AND ((oo_target_key <> 0 AND dt_connect_key = tgt.dc_obj_key) OR (oo_target_key = 0 AND tgt.dc_attributes LIKE '%DataWarehouse;%'))) ">>$THREAD_CMD
  echo "      OR (lt_obj_key IS NULL AND tgt.dc_obj_key = wtsh_connect_key) ">>$THREAD_CMD
  echo "    Where wtsh_job_key = \$JOB_KEY ">>$THREAD_CMD
  echo "    And wtsh_task_key = \$TASK_KEY ">>$THREAD_CMD
  echo "    And wtsh_sequence = \$SEQ;">>$THREAD_CMD
  echo "    .exit">>$THREAD_CMD
  echo "WSL600EOF2\`">>$THREAD_CMD

  # Check warnings in the BTEQ command with exit 0
  echo "   ##" >>$THREAD_CMD
  echo "   # Check for  warning text as BTEQ exits with 0" >>$THREAD_CMD
  echo "   ##" >>$THREAD_CMD
  echo "   BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`" >>$THREAD_CMD
  echo "   if [ \"\$BTEQ_WARNING\" \!\= \"\" ] ">>$THREAD_CMD
  echo "   then">>$THREAD_CMD
  echo "     echo \"Teradata returned with warnings from the BTEQ of \$RES2\"">>$THREAD_CMD
  echo "     echo \"\$RES1\"">>$THREAD_CMD
  echo "   fi">>$THREAD_CMD

  #
  # Get all the information stored in the header table
  # Check that this is a Unix script.
  # If not Unix then unsupported.
  #
  echo "   #">>$THREAD_CMD
  echo "   # See what type of script we have">>$THREAD_CMD
  echo "   # If not a Unix script then not supported">>$THREAD_CMD
  echo "   #">>$THREAD_CMD
  echo "   LINE=\`echo \"\$RES1\" | grep -n \"~~\" | cut -d: -f1\`">>$THREAD_CMD
  echo "   HOST_TYPE=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f3\`">>$THREAD_CMD
  echo "   WORK_DIR=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f4\`">>$THREAD_CMD
  echo "   SCRIPT_TYPE=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "   LOAD_TYPE=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f6\`">>$THREAD_CMD
  echo "   SCRIPT_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f7 | tr -d \" \"\`">>$THREAD_CMD
  echo "   LOAD_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f8 | tr -d \" \"\`">>$THREAD_CMD
  echo "   CONNECT_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f9 | tr -d \" \"\`">>$THREAD_CMD

  echo "   SRC_DSN=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f10\`; export SRC_DSN">>$THREAD_CMD

  echo "   SRC_USER=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f11\`; export SRC_USER">>$THREAD_CMD
  # If Wallet user is set then use it, else revert to use the std extract user
  echo "   if [ \"\$SRC_USER\" \!\= \"\" ] ">>$THREAD_CMD
  echo "   then">>$THREAD_CMD
  echo "     SRC_PWD=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f13\`">>$THREAD_CMD
  # RED_3830 echo "    SRC_PWD=\`echo \$SRC_PWD | sed "s/tdwallet/\\\\\$tdwallet/g"\`; export SRC_PWD">>$THREAD_CMD
  echo "     SRC_PWD=\\\$tdwallet\(\$SRC_PWD\); export SRC_PWD">>$THREAD_CMD
  echo "   else">>$THREAD_CMD
  echo "     SRC_USER=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f12\`; export SRC_USER">>$THREAD_CMD
  echo "     SRC_PWD=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f14\`; export SRC_PWD">>$THREAD_CMD
  echo "   fi">>$THREAD_CMD
  echo "   SRC_USERID=\"\$SRC_USER\"; export SRC_USERID">>$THREAD_CMD

  echo "   TGT_USER=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f15\`; export TGT_USER">>$THREAD_CMD
  # If Wallet user is set then use it, else revert to use the std extract user
  echo "   if [ \"\$TGT_USER\" \!\= \"\" ] ">>$THREAD_CMD
  echo "   then">>$THREAD_CMD
  echo "     TGT_PWD=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f17\`">>$THREAD_CMD
  # RED_3830 echo "    TGT_PWD=\`echo \$TGT_PWD | sed "s/tdwallet/\\\\\$tdwallet/g"\`; export TGT_PWD">>$THREAD_CMD
  echo "     TGT_PWD=\\\$tdwallet\(\$TGT_PWD\); export TGT_PWD">>$THREAD_CMD
  echo "   else">>$THREAD_CMD
  echo "     TGT_USER=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f16\`; export TGT_USER">>$THREAD_CMD
  echo "     TGT_PWD=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f18\`; export TGT_PWD">>$THREAD_CMD
  echo "   fi">>$THREAD_CMD

  echo "   META_USER=\${META_USER-\${DSS_USER}}; export META_USER">>$THREAD_CMD
  echo "   META_PWD=\${META_PWD-\${DSS_PWD}}; export META_PWD">>$THREAD_CMD

  echo "   #">>$THREAD_CMD
  echo "   #">>$THREAD_CMD
  #DEBUG echo "echo \"Header Table:\"">>$THREAD_CMD
  #DEBUG echo "echo \"RES1 =  \$RES1\"">>$THREAD_CMD
  #DEBUG echo "echo \"LINE =  \$LINE\"">>$THREAD_CMD
  #DEBUG echo "echo \"HOST_TYPE  =  \$HOST_TYPE\"">>$THREAD_CMD
  #DEBUG echo "echo \"WORK_DIR  =  \$WORK_DIR\"">>$THREAD_CMD
  #DEBUG echo "echo \"SCRIPT_TYPE  =  \$SCRIPT_TYPE\"">>$THREAD_CMD
  #DEBUG echo "echo \"LOAD_TYPE  =  \$LOAD_TYPE\"">>$THREAD_CMD
  #DEBUG echo "echo \"SCRIPT_KEY  =  \$SCRIPT_KEY\"">>$THREAD_CMD
  #DEBUG echo "echo \"LOAD_KEY  =  \$LOAD_KEY\"">>$THREAD_CMD
  #DEBUG echo "echo \"CONNECT_KEY  =  \$CONNECT_KEY\"">>$THREAD_CMD
  #
  # Not Unix so not supported. We will process through the loop
  # again to pass the unsupported message back to the scheduler.
  #
  echo "    if [ \"\$HOST_TYPE\" != \"U\" ] && [ \"\$HOST_TYPE\" != \"H\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      echo \"Unix scheduler does not support Non Unix loads and scripts: \$HOST_TYPE \"">>$THREAD_CMD
  echo "      TASK_MSG=\"Unix scheduler does not support Non Unix loads and scripts \$HOST_TYPE \"">>$THREAD_CMD
  echo "      TASK_STATUS=-2">>$THREAD_CMD
  echo "      ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "      bMORE=\"Y\"">>$THREAD_CMD
  echo "    else">>$THREAD_CMD
  #
  # Unix script so create a unique script, audit file and error file name
  # which will be located in the work directory as defined in the connection
  # for the load table or script that generated this script.
  #
  echo "      #">>$THREAD_CMD
  echo "      # create a unique name for our script, audit and error trail">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  echo "      THREAD_BASE=\"\${WORK_DIR}wsl\${SEQ}j\${JOB_KEY}t\${TASK_KEY}\"">>$THREAD_CMD
  echo "      THREAD_SH=\"\$THREAD_BASE.sh\"">>$THREAD_CMD
  echo "      THREAD_SCRIPT=\"\$THREAD_BASE.script\"">>$THREAD_CMD
  echo "      THREAD_AUD=\"\$THREAD_BASE.aud\"">>$THREAD_CMD
  echo "      THREAD_ERR=\"\$THREAD_BASE.err\"">>$THREAD_CMD
  echo "      THREAD_BTEQ=\"\$THREAD_BASE.bteq\"">>$THREAD_CMD
  echo "      echo \"Script \$THREAD_SH\"">>$THREAD_CMD
  echo "      echo \"Audit \$THREAD_AUD\"">>$THREAD_CMD
  echo "      echo \"Error \$THREAD_ERR\"">>$THREAD_CMD
  echo "      # Get the actual script">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  #
  # Get the script itself into the unique script file
  # from the ws_wrk_task_scr_line table
  #
  echo "      rm -f \$THREAD_SH ">>$THREAD_CMD
  echo "      RES1=\`bteq <<WSL600EOF3 2>&1">>$THREAD_CMD
  echo "      .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "      .export report file=\$THREAD_SH ">>$THREAD_CMD
  echo "      .set titledashes off ">>$THREAD_CMD
  echo "      .set foldline on 1 ">>$THREAD_CMD
  echo "      .set width 254 ">>$THREAD_CMD
  echo "      .set quiet on ">>$THREAD_CMD
  echo "      .set format off ">>$THREAD_CMD
  echo "      .set heading ' ' ">>$THREAD_CMD
  echo "      Select wtsl_line (TITLE '') ">>$THREAD_CMD
  echo "      From $DSS_METABASE.ws_wrk_task_scr_line ">>$THREAD_CMD
  echo "      Where wtsl_job_key = \$JOB_KEY ">>$THREAD_CMD
  echo "      And wtsl_task_key = \$TASK_KEY ">>$THREAD_CMD
  echo "      And wtsl_sequence = \$SEQ ">>$THREAD_CMD
  echo "      Order by wtsl_line_no; ">>$THREAD_CMD
  echo "      .exit ">>$THREAD_CMD
  echo "WSL600EOF3\`">>$THREAD_CMD
  echo "      RES=\`echo \"\$RES1\" | sed \"s/ ~ /~/g\"\`">>$THREAD_CMD
  #
  # Remove the body of the script from the script file and put it in a
  # separate file that is invoked from the script file. The special token
  # ~~WSL_CUT_HERE~~ tells us where to break the script.
  #
  echo "      CUT_LINE_NO=\`grep -n \"~~WSL_CUT_HERE~~\" \"\$THREAD_SH\" | cut -d: -f1\`">>$THREAD_CMD
  echo "      if [ \"\$CUT_LINE_NO\" ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        sed \"\$CUT_LINE_NO,\\\$d\" \"\$THREAD_SH\" >\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "        echo \\\"\$THREAD_SCRIPT\\\" >>\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "        sed \"1,\${CUT_LINE_NO}d\" \"\$THREAD_SH\" >\"\$THREAD_SCRIPT\"">>$THREAD_CMD
  echo "        mv \"\$THREAD_SH\".tmp \"\$THREAD_SH\"">>$THREAD_CMD
  echo "        chmod 750 \$THREAD_SCRIPT">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  #
  # Execute the script
  # The standard is that the first row on standard output is the result code
  # being either 1=success, -1=warning, -2=error, -3=fatal error
  # The second row on standard out will be the returned message
  #
  echo "      chmod 750 \$THREAD_SH">>$THREAD_CMD
  echo "      \$THREAD_SH \"\$JOB_NAME\" \"\$TASK_NAME\" \$JOB_KEY \$TASK_KEY \$SEQ >\$THREAD_AUD 2>\$THREAD_ERR">>$THREAD_CMD
  echo "      TASK_STATUS=\`head -1 \$THREAD_AUD | tr -d \" \"\`">>$THREAD_CMD
  echo "      TASK_MSG=\`head -2 \$THREAD_AUD | tail -1\`">>$THREAD_CMD
  echo "      if [ \"\$TASK_STATUS\" != \"1\" -a \"\$TASK_STATUS\" != \"-1\" -a \"\$TASK_STATUS\" != \"-2\"  -a \"\$TASK_STATUS\" != \"-3\" ] ">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        TASK_MSG_TMP=\"Invalid return code: \$TASK_STATUS. return_msg: \$TASK_MSG. Check the detail log\"">>$THREAD_CMD
  echo "        TASK_MSG=\`echo \$TASK_MSG_TMP | cut -c1-255\`">>$THREAD_CMD
  echo "        TASK_STATUS=-3">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "      bMORE=\"Y\"">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  echo "      # Put out any additional rows to the workflow audit trail">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  #
  # If there are any additional rows in standard out then write then to
  # the audit trail
  #
  echo "      CMDLEN=0" >> $THREAD_CMD
  echo "      CMDPOP=0" >> $THREAD_CMD
  echo "      AUDLIN=0" >> $THREAD_CMD
  echo "      AUDSTART=\"INSERT INTO $DSS_METABASE.ws_wrk_audit_log (wa_time_stamp,wa_sequence,wa_job,wa_task,wa_status,wa_message,wa_task_key,wa_job_key)\"" >> $THREAD_CMD
  echo "      AUDSTART=\" \$AUDSTART VALUES (CURRENT_TIMESTAMP,\"" >> $THREAD_CMD
  echo "      LIN=\`cat \$THREAD_AUD | wc -l | tr -d \" \"\`" >> $THREAD_CMD
  echo "      echo \"\$LIN audit lines\"" >> $THREAD_CMD
  echo "      if [ \"\$LIN\" != \"2\" ]" >> $THREAD_CMD
  echo "      then" >> $THREAD_CMD
  echo "        AUDLIN=1" >> $THREAD_CMD
  echo "        ROWNUM=0" >> $THREAD_CMD
  echo "        while [ \"\$ROWNUM\" -lt \"\$LIN\" ]" >> $THREAD_CMD
  echo "        do" >> $THREAD_CMD
  echo "          let ROWNUM=\"\$ROWNUM+1\"" >> $THREAD_CMD
  echo "          if [ \"\$ROWNUM\" -gt \"2\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            AUD_TRAIL=\`cat \$THREAD_AUD | head -\$ROWNUM | tail -1| sed \"s/'/''/g\"\`" >> $THREAD_CMD
  echo "            AUD_STR=\`echo \"\$AUDSTART \$SEQ,'\$JOB_NAME','\$TASK_NAME','I','\$AUD_TRAIL',\$TASK_KEY,\$JOB_KEY)\"\`" >> $THREAD_CMD
  #
  # BTEQ has a 64k length limit for a statement, so limit batch statement to 60000 bytes.
  #
  echo "            AUDLEN=\`echo \";\$AUD_STR;\" | wc -c\`" >> $THREAD_CMD
  echo "            let CMDLEN=\"\$CMDLEN + \$AUDLEN\"" >> $THREAD_CMD
  echo "            if [ \"\$CMDPOP\" -eq \"0\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \"\$AUD_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              CMDPOP=1" >> $THREAD_CMD
  echo "            elif [ \"\$CMDLEN\" -gt \"60000\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \";\$AUD_STR;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "              CMDLEN=0" >> $THREAD_CMD
  echo "              CMDPOP=0" >> $THREAD_CMD
  echo "            else" >> $THREAD_CMD
  echo "              echo \";\$AUD_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            fi" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "        done" >> $THREAD_CMD
  echo "        if [ \"\$CMDPOP\" -gt \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          echo \";\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM-2\"" >> $THREAD_CMD
  echo "        if [ \"\$JOB_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          if [ \"\$TASK_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            echo \"UPDATE $DSS_METABASE.ws_wrk_task_run SET wtr_info_count=wtr_info_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            echo \" WHERE wtr_job_key=\$JOB_KEY AND wtr_sequence=\$SEQ AND wtr_task_key=\$TASK_KEY;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "          echo \"UPDATE $DSS_METABASE.ws_wrk_job_run SET wjr_info_count=wjr_info_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo \" WHERE wjr_job_key=\$JOB_KEY AND wjr_sequence=\$SEQ;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "      fi" >> $THREAD_CMD
  #
  # If any rows in standard error then write them to the error/detail trail
  #
  echo "      CMDLEN=0" >> $THREAD_CMD
  echo "      CMDPOP=0" >> $THREAD_CMD
  echo "      ERRLIN=0" >> $THREAD_CMD
  echo "      ERRSTART=\"INSERT INTO $DSS_METABASE.ws_wrk_error_log (wd_time_stamp,wd_sequence,wd_job,wd_task,wd_status,wd_message,wd_task_key,wd_job_key)\"" >> $THREAD_CMD
  echo "      ERRSTART=\" \$ERRSTART VALUES (CURRENT_TIMESTAMP,\"" >> $THREAD_CMD
  echo "      LIN=\`cat \$THREAD_ERR | wc -l | tr -d \" \"\`" >> $THREAD_CMD
  echo "      echo \"\$LIN error lines\"" >> $THREAD_CMD
  echo "      if [ \"\$LIN\" -gt \"0\" ]" >> $THREAD_CMD
  echo "      then" >> $THREAD_CMD
  echo "        ERRLIN=1" >> $THREAD_CMD
  echo "        ROWNUM=0" >> $THREAD_CMD
  echo "        while [ \"\$ROWNUM\" -lt \"\$LIN\" ]" >> $THREAD_CMD
  echo "        do" >> $THREAD_CMD
  echo "          let ROWNUM=\"\$ROWNUM+1\"" >> $THREAD_CMD
  echo "          if [ \"\$ROWNUM\" -gt \"0\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            ERR_TRAIL=\`cat \$THREAD_ERR | head -\$ROWNUM | tail -1| sed \"s/'/''/g\"\`" >> $THREAD_CMD
  echo "            ERR_STR=\"\$ERRSTART \$SEQ,'\$JOB_NAME','\$TASK_NAME','I','\$ERR_TRAIL',\$TASK_KEY,\$JOB_KEY ) \"" >> $THREAD_CMD
  #
  # BTEQ has a 64k length limit for a statement, so limit batch statement to 60000 bytes.
  #
  echo "            ERRLEN=\`echo \";\$ERR_STR;\" | wc -c\`" >> $THREAD_CMD
  echo "            let CMDLEN=\"\$CMDLEN + \$ERRLEN\"" >> $THREAD_CMD
  echo "            if [ \"\$CMDPOP\" -eq \"0\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \"\$ERR_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              CMDPOP=1" >> $THREAD_CMD
  echo "            elif [ \"\$CMDLEN\" -gt \"60000\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \";\$ERR_STR;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "              CMDLEN=0" >> $THREAD_CMD
  echo "              CMDPOP=0" >> $THREAD_CMD
  echo "            else" >> $THREAD_CMD
  echo "              echo \";\$ERR_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            fi" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "        done" >> $THREAD_CMD
  echo "        if [ \"\$CMDPOP\" -gt \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          echo \";\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM-2\"" >> $THREAD_CMD
  echo "        if [ \"\$JOB_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          if [ \"\$TASK_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            echo \"UPDATE $DSS_METABASE.ws_wrk_task_run SET wtr_detail_count=wtr_detail_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            echo \" WHERE wtr_job_key=\$JOB_KEY AND wtr_sequence=\$SEQ AND wtr_task_key=\$TASK_KEY;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "          echo \"UPDATE $DSS_METABASE.ws_wrk_job_run SET wjr_detail_count=wjr_detail_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo \" WHERE wjr_job_key=\$JOB_KEY AND wjr_sequence=\$SEQ;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "      fi" >> $THREAD_CMD
  echo "      echo \" .exit\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "      if [ \"\$AUDLIN\" -gt \"0\" ] || [ \"\$ERRLIN\" -gt \"0\" ]" >> $THREAD_CMD
  echo "      then" >> $THREAD_CMD
  echo "        cat \$THREAD_BTEQ | bteq .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD} > /dev/null 2>&1" >> $THREAD_CMD
  echo "      fi" >> $THREAD_CMD
  echo "    fi" >> $THREAD_CMD
  #
  # Here if we returned a 3 from ws_job_exec_nnn which indicates an ODBC based load
  # Not supported under Unix
  #
  echo "  elif [ \"\$RET_CODE\" = \"3\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "    REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    echo \"Unix scheduler does not support ODBC based load\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Unix scheduler does not support ODBC based loads \$HOST_TYPE \"">>$THREAD_CMD
  echo "    TASK_STATUS=-2">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 4 from ws_job_exec_nnn which indicates a CUBE create
  # Not supported under Unix
  #
  echo "  elif [ \"\$RET_CODE\" = \"4\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    echo \"CUBE Create Called\"">>$THREAD_CMD
  echo "    RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "    REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    echo \"Unix scheduler does not support CUBE creates\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Unix scheduler does not support CUBE creates \$HOST_TYPE \"">>$THREAD_CMD
  echo "    TASK_STATUS=-2">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 5 from ws_job_exec_nnn which indicates a CUBE process
  # Not supported under Unix
  #
  echo "  elif [ \"\$RET_CODE\" = \"5\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    echo \"CUBE Process Called\"">>$THREAD_CMD
  echo "    RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "    REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    echo \"Unix scheduler does not support CUBE processing\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Unix scheduler does not support CUBE processing \$HOST_TYPE \"">>$THREAD_CMD
  echo "    TASK_STATUS=-2">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 11 from ws_job_exec_nnn which indicates an export
  #
  echo "  elif [ \"\$RET_CODE\" = \"11\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  #
  # Code below if a breakout script is required for an export.
  # the script is loaded into the table ws_wrk_task_scr_line
  # and a header table exists providing information such as
  # the host platform etc.
  #
  # Get the information returned from ws_job_exec_nnn which is
  # the job and task keys
  #
  echo "    echo \"Script Called\"">>$THREAD_CMD
  echo "    RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "    REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    # Break out the returned variables">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    # Get the information from the script header file">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # Execute a command to get information from the header
  # table about the script we are to run
  #
  echo "    RES1=\`bteq <<WSL600EOF6 2>&1">>$THREAD_CMD
  echo "    .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "    .set width 254">>$THREAD_CMD
  echo "    Select '~'||'~'||COALESCE(wtsh_host_type,'')||'~'|| ">>$THREAD_CMD
  echo "         COALESCE(wtsh_work_dir,'')||'~'|| ">>$THREAD_CMD
  echo "         COALESCE(wtsh_script_type,'')||'~'|| ">>$THREAD_CMD
  echo "         COALESCE(wtsh_load_type,'')||'~'|| ">>$THREAD_CMD
  echo "         CAST(COALESCE(wtsh_script_key,0) AS VARCHAR(18))||'~'|| ">>$THREAD_CMD
  echo "         CAST(COALESCE(wtsh_load_key,0) AS VARCHAR(18))||'~'|| ">>$THREAD_CMD
  echo "         CAST(COALESCE(wtsh_connect_key,0) AS VARCHAR(18))||'~'|| ">>$THREAD_CMD
  # RED_3830 echo "         CASE WHEN src.dc_authentication like '%DefODBCUser~= 2%'" >>$THREAD_CMD
  # echo "                      THEN  SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "                 THEN SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "                                                                                                                                          CHARACTER_LENGTH(src.dc_authentication)),';')," >>$THREAD_CMD
  echo "                                                         CASE WHEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') > 0" >>$THREAD_CMD
  echo "                                                              THEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletUser~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') - 1" >>$THREAD_CMD
  echo "                                                              ELSE CHARACTER_LENGTH(src.dc_authentication)" >>$THREAD_CMD
  echo "                                                         END)" >>$THREAD_CMD
  # RED_3830 echo "                      ELSE src.dc_extract_userid " >>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END ||'~'|| " >>$THREAD_CMD
  echo "                      src.dc_extract_userid ||'~'||" >>$THREAD_CMD
  # RED_3830 echo "         CASE WHEN src.dc_authentication like '%DefODBCUser~= 2%'">>$THREAD_CMD
  # echo "                      THEN  'tdwallet(' ||  SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "               THEN SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "                                                                                                                                          CHARACTER_LENGTH(src.dc_authentication)),';'),">>$THREAD_CMD
  echo "                                                         CASE WHEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') > 0">>$THREAD_CMD
  echo "                                                              THEN INDEX( SUBSTR(src.dc_authentication,  INDEX(src.dc_authentication, 'TDWalletStr~=') + INDEX(SUBSTR(src.dc_authentication, INDEX(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               CHARACTER_LENGTH(src.dc_authentication)),';'), 100),';') - 1">>$THREAD_CMD
  echo "                                                              ELSE CHARACTER_LENGTH(src.dc_authentication)">>$THREAD_CMD
  echo "                                                         END)">>$THREAD_CMD
  # RED_3830 echo "                      ELSE   src.dc_extract_pwd">>$THREAD_CMD
  # echo "                 END ||'~' DATA_STREAM ">>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END ||'~'|| " >>$THREAD_CMD
  echo "                      src.dc_extract_pwd ||'~' DATA_STREAM " >>$THREAD_CMD
  echo "    From $DSS_METABASE.ws_wrk_task_scr_hdr ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_obj_object ON (SELECT MAX(ec_src_table) FROM $DSS_METABASE.ws_export_col WHERE ec_obj_key = wtsh_load_key) = oo_name ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_dbc_target ON oo_target_key = dt_target_key ">>$THREAD_CMD
  echo "    LEFT OUTER JOIN $DSS_METABASE.ws_dbc_connect src ON (oo_target_key <> 0 AND dt_connect_key = src.dc_obj_key) OR (oo_target_key = 0 AND src.dc_attributes LIKE '%DataWarehouse;%') ">>$THREAD_CMD
  echo "    Where wtsh_job_key = \$JOB_KEY ">>$THREAD_CMD
  echo "    And wtsh_task_key = \$TASK_KEY ">>$THREAD_CMD
  echo "    And wtsh_sequence = \$SEQ;">>$THREAD_CMD
  echo "    .exit">>$THREAD_CMD
  echo "WSL600EOF6\`">>$THREAD_CMD
  #
  # Get all the information stored in the header table
  # Check that this is a Unix script.
  # If not Unix then unsupported.
  #
  echo "    #">>$THREAD_CMD
  echo "    # See what type of script we have">>$THREAD_CMD
  echo "    # If not a Unix script then not supported">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    LINE=\`echo \"\$RES1\" | grep -n \"~~\" | cut -d: -f1\`">>$THREAD_CMD
  echo "    HOST_TYPE=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f3\`">>$THREAD_CMD
  echo "    WORK_DIR=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f4\`">>$THREAD_CMD
  echo "    SCRIPT_TYPE=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "    LOAD_TYPE=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f6\`">>$THREAD_CMD
  echo "    SCRIPT_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f7 | tr -d \" \"\`">>$THREAD_CMD
  echo "    LOAD_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f8 | tr -d \" \"\`">>$THREAD_CMD
  echo "    CONNECT_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f9 | tr -d \" \"\`">>$THREAD_CMD

  echo "    SRC_USER=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f10\`; export SRC_USER">>$THREAD_CMD
  # If Wallet user is set then use it, else revert to use the std extract user
  echo "    if [ \"\$SRC_USER\" \!\= \"\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      SRC_PWD=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f12\`">>$THREAD_CMD
  # RED_3830 echo "    SRC_PWD=\`echo \$SRC_PWD | sed "s/tdwallet/\\\\\$tdwallet/g"\`; export SRC_PWD">>$THREAD_CMD
  echo "      SRC_PWD=\\\$tdwallet\(\$SRC_PWD\); export SRC_PWD">>$THREAD_CMD
  echo "    else">>$THREAD_CMD
  echo "      SRC_USER=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f11\`; export SRC_USER">>$THREAD_CMD
  echo "      SRC_PWD=\`echo \"\$RES1\" | head -\$LINE | tail -1 | cut -d \"~\" -f13\`; export SRC_PWD">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD

  echo "    META_USER=\${META_USER-\${DSS_USER}}; export META_USER">>$THREAD_CMD
  echo "    META_PWD=\${META_PWD-\${DSS_PWD}}; export META_PWD">>$THREAD_CMD

  echo "    #">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #DEBUG echo "echo \"Header Table:\"">>$THREAD_CMD
  #DEBUG echo "echo \"RES1 =  \$RES1\"">>$THREAD_CMD
  #DEBUG echo "echo \"LINE =  \$LINE\"">>$THREAD_CMD
  #DEBUG echo "echo \"HOST_TYPE  =  \$HOST_TYPE\"">>$THREAD_CMD
  #DEBUG echo "echo \"WORK_DIR  =  \$WORK_DIR\"">>$THREAD_CMD
  #DEBUG echo "echo \"SCRIPT_TYPE  =  \$SCRIPT_TYPE\"">>$THREAD_CMD
  #DEBUG echo "echo \"LOAD_TYPE  =  \$LOAD_TYPE\"">>$THREAD_CMD
  #DEBUG echo "echo \"SCRIPT_KEY  =  \$SCRIPT_KEY\"">>$THREAD_CMD
  #DEBUG echo "echo \"LOAD_KEY  =  \$LOAD_KEY\"">>$THREAD_CMD
  #DEBUG echo "echo \"CONNECT_KEY  =  \$CONNECT_KEY\"">>$THREAD_CMD
  #
  # Not Unix so not supported. We will process through the loop
  # again to pass the unsupported message back to the scheduler.
  #
  echo "    if [ \"\$HOST_TYPE\" != \"U\" ] && [ \"\$HOST_TYPE\" != \"H\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      echo \"Unix scheduler does not support Non Unix loads and scripts: \$HOST_TYPE \"">>$THREAD_CMD
  echo "      TASK_MSG=\"Unix scheduler does not support Non Unix loads and scripts \$HOST_TYPE \"">>$THREAD_CMD
  echo "      TASK_STATUS=-2">>$THREAD_CMD
  echo "      ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "      bMORE=\"Y\"">>$THREAD_CMD
  echo "    else">>$THREAD_CMD
  #
  # Unix script so create a unique script, audit file and error file name
  # which will be located in the work directory as defined in the connection
  # for the load table or script that generated this script.
  #
  echo "      #">>$THREAD_CMD
  echo "      # create a unique name for our script, audit and error trail">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  echo "      THREAD_BASE=\"\${WORK_DIR}wsl\${SEQ}j\${JOB_KEY}t\${TASK_KEY}\"">>$THREAD_CMD
  echo "      THREAD_SH=\"\$THREAD_BASE.sh\"">>$THREAD_CMD
  echo "      THREAD_SCRIPT=\"\$THREAD_BASE.script\"">>$THREAD_CMD
  echo "      THREAD_AUD=\"\$THREAD_BASE.aud\"">>$THREAD_CMD
  echo "      THREAD_ERR=\"\$THREAD_BASE.err\"">>$THREAD_CMD
  echo "      THREAD_BTEQ=\"\$THREAD_BASE.bteq\"">>$THREAD_CMD
  echo "      echo \"Script \$THREAD_SH\"">>$THREAD_CMD
  echo "      echo \"Audit \$THREAD_AUD\"">>$THREAD_CMD
  echo "      echo \"Error \$THREAD_ERR\"">>$THREAD_CMD
  echo "      # Get the actual script">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  #
  # Get the script itself into the unique script file
  # from the ws_wrk_task_scr_line table
  #
  echo "      rm -f \$THREAD_SH ">>$THREAD_CMD
  echo "      RES1=\`bteq <<WSL600EOF7 2>&1">>$THREAD_CMD
  echo "      .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "      .export report file=\$THREAD_SH ">>$THREAD_CMD
  echo "      .set titledashes off ">>$THREAD_CMD
  echo "      .set foldline on 1 ">>$THREAD_CMD
  echo "      .set width 254 ">>$THREAD_CMD
  echo "      .set quiet on ">>$THREAD_CMD
  echo "      .set format off ">>$THREAD_CMD
  echo "      .set heading ' ' ">>$THREAD_CMD
  echo "      Select wtsl_line (TITLE '') ">>$THREAD_CMD
  echo "      From $DSS_METABASE.ws_wrk_task_scr_line ">>$THREAD_CMD
  echo "      Where wtsl_job_key = \$JOB_KEY ">>$THREAD_CMD
  echo "      And wtsl_task_key = \$TASK_KEY ">>$THREAD_CMD
  echo "      And wtsl_sequence = \$SEQ ">>$THREAD_CMD
  echo "      Order by wtsl_line_no; ">>$THREAD_CMD
  echo "      .exit ">>$THREAD_CMD
  echo "WSL600EOF7\`">>$THREAD_CMD
  echo "      RES2=\$?" >>$THREAD_CMD
  #DEBUG echo "echo \"RES1 =  \$RES1\"">>$THREAD_CMD
  #DEBUG echo "echo \"RES2 =  \$RES2\"">>$THREAD_CMD
  #
  # Remove the body of the script from the script file and put it in a
  # separate file that is invoked from the script file. The special token
  # ~~WSL_CUT_HERE~~ tells us where to break the script.
  #
  echo "      CUT_LINE_NO=\`grep -n \"~~WSL_CUT_HERE~~\" \"\$THREAD_SH\" | cut -d: -f1\`">>$THREAD_CMD
  echo "      if [ \"\$CUT_LINE_NO\" ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        sed \"\$CUT_LINE_NO,\\\$d\" \"\$THREAD_SH\" >\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "        echo \\\"\$THREAD_SCRIPT\\\" >>\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "        sed \"1,\${CUT_LINE_NO}d\" \"\$THREAD_SH\" >\"\$THREAD_SCRIPT\"">>$THREAD_CMD
  echo "        mv \"\$THREAD_SH\".tmp \"\$THREAD_SH\"">>$THREAD_CMD
  echo "        chmod 750 \$THREAD_SCRIPT">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  #
  # Execute the script
  # The standard is that the first row on standard output is the result code
  # being either 1=success, -1=warning, -2=error, -3=fatal error
  # The second row on standard out will be the returned message
  #
  echo "      chmod 750 \$THREAD_SH">>$THREAD_CMD
  echo "      \$THREAD_SH \"\$JOB_NAME\" \"\$TASK_NAME\" \$JOB_KEY \$TASK_KEY \$SEQ >\$THREAD_AUD 2>\$THREAD_ERR">>$THREAD_CMD
  echo "      TASK_STATUS=\`head -1 \$THREAD_AUD | tr -d \" \"\`">>$THREAD_CMD
  echo "      TASK_MSG=\`head -2 \$THREAD_AUD | tail -1\`">>$THREAD_CMD
  echo "      if [ \"\$TASK_STATUS\" != \"1\" -a \"\$TASK_STATUS\" != \"-1\" -a \"\$TASK_STATUS\" != \"-2\"  -a \"\$TASK_STATUS\" != \"-3\" ] ">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        TASK_MSG_TMP=\"Invalid return code: \$TASK_STATUS. return_msg: \$TASK_MSG\"">>$THREAD_CMD
  echo "        TASK_MSG=\`echo \$TASK_MSG_TMP | cut -c1-255\`">>$THREAD_CMD
  echo "        TASK_STATUS=-3">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "      bMORE=\"Y\"">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  echo "      # Put out any additional rows to the workflow audit trail">>$THREAD_CMD
  echo "      #">>$THREAD_CMD
  #
  # If there are any additional rows in standard out then write then to
  # the audit trail
  #
  echo "      CMDLEN=0" >> $THREAD_CMD
  echo "      CMDPOP=0" >> $THREAD_CMD
  echo "      AUDLIN=0" >> $THREAD_CMD
  echo "      AUDSTART=\"INSERT INTO $DSS_METABASE.ws_wrk_audit_log (wa_time_stamp,wa_sequence,wa_job,wa_task,wa_status,wa_message,wa_task_key,wa_job_key)\"" >> $THREAD_CMD
  echo "      AUDSTART=\" \$AUDSTART VALUES (CURRENT_TIMESTAMP,\"" >> $THREAD_CMD
  echo "      LIN=\`cat \$THREAD_AUD | wc -l | tr -d \" \"\`" >> $THREAD_CMD
  echo "      echo \"\$LIN audit lines\"" >> $THREAD_CMD
  echo "      if [ \"\$LIN\" != \"2\" ]" >> $THREAD_CMD
  echo "      then" >> $THREAD_CMD
  echo "        AUDLIN=1" >> $THREAD_CMD
  echo "        ROWNUM=0" >> $THREAD_CMD
  echo "        while [ \"\$ROWNUM\" -lt \"\$LIN\" ]" >> $THREAD_CMD
  echo "        do" >> $THREAD_CMD
  echo "          let ROWNUM=\"\$ROWNUM+1\"" >> $THREAD_CMD
  echo "          if [ \"\$ROWNUM\" -gt \"2\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            AUD_TRAIL=\`cat \$THREAD_AUD | head -\$ROWNUM | tail -1| sed \"s/'/''/g\"\`" >> $THREAD_CMD
  echo "            AUD_STR=\`echo \"\$AUDSTART \$SEQ,'\$JOB_NAME','\$TASK_NAME','I','\$AUD_TRAIL',\$TASK_KEY,\$JOB_KEY)\"\`" >> $THREAD_CMD
  #
  # BTEQ has a 64k length limit for a statement, so limit batch statement to 60000 bytes.
  #
  echo "            AUDLEN=\`echo \";\$AUD_STR;\" | wc -c\`" >> $THREAD_CMD
  echo "            let CMDLEN=\"\$CMDLEN + \$AUDLEN\"" >> $THREAD_CMD
  echo "            if [ \"\$CMDPOP\" -eq \"0\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \"\$AUD_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              CMDPOP=1" >> $THREAD_CMD
  echo "            elif [ \"\$CMDLEN\" -gt \"60000\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \";\$AUD_STR;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "              CMDLEN=0" >> $THREAD_CMD
  echo "              CMDPOP=0" >> $THREAD_CMD
  echo "            else" >> $THREAD_CMD
  echo "              echo \";\$AUD_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            fi" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "        done" >> $THREAD_CMD
  echo "        if [ \"\$CMDPOP\" -gt \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          echo \";\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM-2\"" >> $THREAD_CMD
  echo "        if [ \"\$JOB_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          if [ \"\$TASK_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            echo \"UPDATE $DSS_METABASE.ws_wrk_task_run SET wtr_info_count=wtr_info_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            echo \" WHERE wtr_job_key=\$JOB_KEY AND wtr_sequence=\$SEQ AND wtr_task_key=\$TASK_KEY;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "          echo \"UPDATE $DSS_METABASE.ws_wrk_job_run SET wjr_info_count=wjr_info_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo \" WHERE wjr_job_key=\$JOB_KEY AND wjr_sequence=\$SEQ;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "      fi" >> $THREAD_CMD
  #
  # If any rows in standard error then write them to the error/detail trail
  #
  echo "      CMDLEN=0" >> $THREAD_CMD
  echo "      CMDPOP=0" >> $THREAD_CMD
  echo "      ERRLIN=0" >> $THREAD_CMD
  echo "      ERRSTART=\"INSERT INTO $DSS_METABASE.ws_wrk_error_log (wd_time_stamp,wd_sequence,wd_job,wd_task,wd_status,wd_message,wd_task_key,wd_job_key)\"" >> $THREAD_CMD
  echo "      ERRSTART=\" \$ERRSTART VALUES (CURRENT_TIMESTAMP,\"" >> $THREAD_CMD
  echo "      LIN=\`cat \$THREAD_ERR | wc -l | tr -d \" \"\`" >> $THREAD_CMD
  echo "      echo \"\$LIN error lines\"" >> $THREAD_CMD
  echo "      if [ \"\$LIN\" != \"2\" ]" >> $THREAD_CMD
  echo "      then" >> $THREAD_CMD
  echo "        ERRLIN=1" >> $THREAD_CMD
  echo "        ROWNUM=0" >> $THREAD_CMD
  echo "        while [ \"\$ROWNUM\" -lt \"\$LIN\" ]" >> $THREAD_CMD
  echo "        do" >> $THREAD_CMD
  echo "          let ROWNUM=\"\$ROWNUM+1\"" >> $THREAD_CMD
  echo "          if [ \"\$ROWNUM\" -gt \"0\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            ERR_TRAIL=\`cat \$THREAD_ERR | head -\$ROWNUM | tail -1| sed \"s/'/''/g\"\`" >> $THREAD_CMD
  echo "            ERR_STR=\"\$ERRSTART \$SEQ,'\$JOB_NAME','\$TASK_NAME','I','\$ERR_TRAIL',\$TASK_KEY,\$JOB_KEY ) \"" >> $THREAD_CMD
  #
  # BTEQ has a 64k length limit for a statement, so limit batch statement to 60000 bytes.
  #
  echo "            ERRLEN=\`echo \";\$ERR_STR;\" | wc -c\`" >> $THREAD_CMD
  echo "            let CMDLEN=\"\$CMDLEN + \$ERRLEN\"" >> $THREAD_CMD
  echo "            if [ \"\$CMDPOP\" -eq \"0\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \"\$ERR_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              CMDPOP=1" >> $THREAD_CMD
  echo "            elif [ \"\$CMDLEN\" -gt \"60000\" ]" >> $THREAD_CMD
  echo "            then" >> $THREAD_CMD
  echo "              echo \";\$ERR_STR;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "              echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "              CMDLEN=0" >> $THREAD_CMD
  echo "              CMDPOP=0" >> $THREAD_CMD
  echo "            else" >> $THREAD_CMD
  echo "              echo \";\$ERR_STR\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            fi" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "        done" >> $THREAD_CMD
  echo "        if [ \"\$CMDPOP\" -gt \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          echo \";\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo Terminating BTEQ Command with \$CMDLEN chars \$ROWNUM total messages" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM-2\"" >> $THREAD_CMD
  echo "        if [ \"\$JOB_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "        then" >> $THREAD_CMD
  echo "          if [ \"\$TASK_KEY\" -ne \"0\" ]" >> $THREAD_CMD
  echo "          then" >> $THREAD_CMD
  echo "            echo \"UPDATE $DSS_METABASE.ws_wrk_task_run SET wtr_detail_count=wtr_detail_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "            echo \" WHERE wtr_job_key=\$JOB_KEY AND wtr_sequence=\$SEQ AND wtr_task_key=\$TASK_KEY;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          fi" >> $THREAD_CMD
  echo "          echo \"UPDATE $DSS_METABASE.ws_wrk_job_run SET wjr_detail_count=wjr_detail_count+\$ROWNUM\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "          echo \" WHERE wjr_job_key=\$JOB_KEY AND wjr_sequence=\$SEQ;\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "        fi" >> $THREAD_CMD
  echo "      fi" >> $THREAD_CMD
  echo "      echo \" .exit\" >> \$THREAD_BTEQ" >> $THREAD_CMD
  echo "      if [ \"\$AUDLIN\" -gt \"0\" ] || [ \"\$ERRLIN\" -gt \"0\" ]" >> $THREAD_CMD
  echo "      then" >> $THREAD_CMD
  echo "        cat \$THREAD_BTEQ | bteq .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD} > /dev/null 2>&1" >> $THREAD_CMD
  echo "      fi" >> $THREAD_CMD
  echo "    fi" >> $THREAD_CMD
  #
  # Here if we returned a 12 from ws_job_exec_nnn which indicates a Native ODBC based load
  # Not supported under Unix
  #
  echo "  elif [ \"\$RET_CODE\" = \"12\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "    REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    echo \"Unix scheduler does not support Native ODBC based load\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Unix scheduler does not support Native ODBC based loads \$HOST_TYPE \"">>$THREAD_CMD
  echo "    TASK_STATUS=-2">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 90 or 91 from ws_job_exec_nnn which indicates a BDA Server task
  # 90 indicates BDA Server tasks to run completely in the BDA Server in Scheduler mode;
  #    a rejoin which does not attempt post actions is to be used.
  # 91 indicates BDA Server tasks to run partially in the BDA Server in Scheduler mode;
  #    pre and post actions cannot be performed in the BDA Server for non-Hive targets;
  #    these need to be done in the Scheduler, not the BDA Server;
  #    a rejoin which does attempt post actions is to be used.
  #
  echo "  elif [ \"\$RET_CODE\" -eq 90 -o \"\$RET_CODE\" -eq 91 ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "    REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    PROC_STMT=\`echo \"\$RES1\" | head -\$LINE | tail -1 | head -1\`">>$THREAD_CMD
  echo "    BDA_SRVR_HOST=\`echo \"\$PROC_STMT\" | sed -e\"s@~@[TILDE]@g\" -e\"s@\\\\[WSH]@~@g\" -e\"s@.*CP_BDA_Host~\\\\([^~]*\\\\)~.*@\\\\1@\" -e\"s@\\\\[TILDE]@~@g\"\`">>$THREAD_CMD
  echo "    BDA_SRVR_PORT=\`echo \"\$PROC_STMT\" | sed -e\"s@~@[TILDE]@g\" -e\"s@\\\\[WSH]@~@g\" -e\"s@.*CP_BDA_Port~\\\\([^~]*\\\\)~.*@\\\\1@\" -e\"s@\\\\[TILDE]@~@g\"\`">>$THREAD_CMD
  echo "    BDA_SRVR_APP=\`echo \"\$PROC_STMT\" | sed -e\"s@~@[TILDE]@g\" -e\"s@\\\\[WSH]@~@g\" -e\"s@.*CP_BDA_Context~\\\\([^~]*\\\\)~.*@\\\\1@\" -e\"s@\\\\[TILDE]@~@g\"\`">>$THREAD_CMD
  echo "    BDA_TASK_OBJ_KEY=\`echo \"\$PROC_STMT\" | sed -e\"s@~@[TILDE]@g\" -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_ObjKey~\\\\([^~]*\\\\)~.*@\\\\1@\" -e\"s@\\\\[TILDE]@~@g\"\`">>$THREAD_CMD
  echo "    BDA_TASK_ACTION=\`echo \"\$PROC_STMT\" | sed -e\"s@~@[TILDE]@g\" -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_Action~\\\\([^~]*\\\\)~.*@\\\\1@\" -e\"s@\\\\[TILDE]@~@g\"\`">>$THREAD_CMD
  echo "    BDA_SECRET_ID=\`echo \"\$PROC_STMT\" | sed -e\"s@~@[TILDE]@g\" -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_SecretId~\\\\([^~]*\\\\)~.*@\\\\1@\" -e\"s@\\\\[TILDE]@~@g\"\`">>$THREAD_CMD
  echo "    BDA_SECRET=\`echo \"\$PROC_STMT\" | sed -e\"s@~@[TILDE]@g\" -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_Secret~\\\\([^~]*\\\\)~.*@\\\\1@\" -e\"s@\\\\[TILDE]@~@g\"\`">>$THREAD_CMD
  echo "    BDA_TASK_SEQ=\"\$SEQ\"">>$THREAD_CMD
  echo "    BDA_TASK_KEY=\"\$TASK_KEY\"">>$THREAD_CMD
  echo "    PROC_STMT=\"no statement\"">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    JSON_PATN_WHITESPACE=\"[ \\\\t\\\\n\\\\r]*\"">>$THREAD_CMD
  echo "    JSON_PATN_NUMBER=\"\\\\([-]\\\\{0,1\\\\}[1-9][0-9]*\\\\)\"">>$THREAD_CMD
  echo "    JSON_PATN_STRING=\"\\\"\\\\(\\\\([^\\\"\\\\\\\\]\\\\|\\\\\\\\[\\\"\\\\\\\\/bfnrt]\\\\)*\\\\)\\\"\"">>$THREAD_CMD
  echo "    JSON_PATN_NVP_PREFIX=\"[{,]\"">>$THREAD_CMD
  echo "    JSON_PATN_NVP_SUFFIX=\"[,}]\"">>$THREAD_CMD
  echo "    BDA_TASK_RESPONSE_PATN_RUN_KEY=\"\$JSON_PATN_NVP_PREFIX\$JSON_PATN_WHITESPACE\\\"runId\\\"\$JSON_PATN_WHITESPACE:\$JSON_PATN_WHITESPACE\$JSON_PATN_NUMBER\$JSON_PATN_WHITESPACE\$JSON_PATN_NVP_SUFFIX\"">>$THREAD_CMD
  echo "    BDA_TASK_RESPONSE_PATN_TASK_STATUS=\"\$JSON_PATN_NVP_PREFIX\$JSON_PATN_WHITESPACE\\\"taskStatus\\\"\$JSON_PATN_WHITESPACE:\$JSON_PATN_WHITESPACE\$JSON_PATN_STRING\$JSON_PATN_WHITESPACE\$JSON_PATN_NVP_SUFFIX\"">>$THREAD_CMD
  echo "    BDA_TASK_RESPONSE_PATN_ERROR_MSG=\"\$JSON_PATN_NVP_PREFIX\$JSON_PATN_WHITESPACE\\\"message\\\"\$JSON_PATN_WHITESPACE:\$JSON_PATN_WHITESPACE\$JSON_PATN_STRING\$JSON_PATN_WHITESPACE\$JSON_PATN_NVP_SUFFIX\"">>$THREAD_CMD
  echo "    BDA_TASK_DATA=\"{\\\"objectId\\\":\$BDA_TASK_OBJ_KEY, \\\"actionType\\\":\$BDA_TASK_ACTION, \\\"sequenceId\\\":\$BDA_TASK_SEQ, \\\"taskId\\\":\$BDA_TASK_KEY}\"">>$THREAD_CMD
  echo "    BDA_TASK_URL=\"http://\$BDA_SRVR_HOST:\$BDA_SRVR_PORT/\$BDA_SRVR_APP/rest/v1/task\"">>$THREAD_CMD
  echo "    BDA_AUTH_HMAC=\`printf '%s\\000%s' \"\$BDA_TASK_URL\" \"\$BDA_TASK_DATA\" | openssl dgst -sha256 -hmac \"\$BDA_SECRET\" -binary | openssl enc -base64\`">>$THREAD_CMD
  echo "    BDA_AUTH_HEADER=\"Authorization: WSL-SharedSecret-v1 SecretType=Metadata, SecretId=\$BDA_SECRET_ID, HMAC=\\\"\$BDA_AUTH_HMAC\\\"\"">>$THREAD_CMD
  echo "    BDA_TASK_RESPONSE=\`curl -s -S -i -H\"Accept: application/json\" -H\"Content-Type: application/json\" -H\"\$BDA_AUTH_HEADER\" -d\"\$BDA_TASK_DATA\" \"\$BDA_TASK_URL\" 2>&1\`">>$THREAD_CMD
  echo "    BDA_TASK_CURL_STATUS_CODE=\"\$?\"">>$THREAD_CMD
  echo "    echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | grep -e\"\$BDA_TASK_RESPONSE_PATN_RUN_KEY\" >/dev/null">>$THREAD_CMD
  echo "    if [ \"\$?\" -eq 0 ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      BDA_TASK_RUN_KEY=\`echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | sed -e\"s@.*\$BDA_TASK_RESPONSE_PATN_RUN_KEY.*@\\1@\"\`">>$THREAD_CMD
  echo "    else">>$THREAD_CMD
  echo "      BDA_TASK_RUN_KEY=\"\"">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    while [ true ]">>$THREAD_CMD
  echo "    do">>$THREAD_CMD
  echo "      if [ \"\$BDA_TASK_CURL_STATUS_CODE\" -ne 0 ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        BDA_TASK_CURL_STATUS_MSG=\"\$BDA_TASK_RESPONSE\"">>$THREAD_CMD
  echo "        TASK_MSG=\"BDA connection failure: \$BDA_TASK_CURL_STATUS_MSG\"">>$THREAD_CMD
  echo "        TASK_STATUS=-3">>$THREAD_CMD
  echo "        break">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      BDA_TASK_HTTP_STATUS_CODE=\`echo \"\$BDA_TASK_RESPONSE\" | head -1 | cut -d\" \" -f2\`">>$THREAD_CMD
  echo "      if [ \"\$BDA_TASK_HTTP_STATUS_CODE\" -ge 400 ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | grep -e\"\$BDA_TASK_RESPONSE_PATN_ERROR_MSG\" >/dev/null">>$THREAD_CMD
  echo "        if [ \"\$?\" -eq 0 ]">>$THREAD_CMD
  echo "        then">>$THREAD_CMD
  echo "          BDA_TASK_ERROR_MSG=\`echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | sed -e\"s@.*\$BDA_TASK_RESPONSE_PATN_ERROR_MSG.*@\\1@\"\`">>$THREAD_CMD
  echo "          TASK_MSG=\"BDA operation failed: \$BDA_TASK_ERROR_MSG\"">>$THREAD_CMD
  echo "        else">>$THREAD_CMD
  echo "          BDA_TASK_HTTP_STATUS_MSG=\`echo \"\$BDA_TASK_RESPONSE\" | head -1 | cut -d\" \" -f3-\`">>$THREAD_CMD
  echo "          TASK_MSG=\"BDA connection failure: \$BDA_TASK_HTTP_STATUS_CODE \$BDA_TASK_HTTP_STATUS_MSG\"">>$THREAD_CMD
  echo "        fi">>$THREAD_CMD
  echo "        TASK_STATUS=-3">>$THREAD_CMD
  echo "        break">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | grep -e\"\$BDA_TASK_RESPONSE_PATN_TASK_STATUS\" >/dev/null">>$THREAD_CMD
  echo "      if [ \"\$?\" -ne 0 ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        TASK_MSG=\"BDA operation failed: Invalid response message.\"">>$THREAD_CMD
  echo "        TASK_STATUS=-3">>$THREAD_CMD
  echo "        break">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      BDA_TASK_STATUS=\`echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | sed -e\"s@.*\$BDA_TASK_RESPONSE_PATN_TASK_STATUS.*@\\1@\"\`">>$THREAD_CMD
  echo "      if [ \"\$BDA_TASK_STATUS\" != \"P\" -a \"\$BDA_TASK_STATUS\" != \"R\" ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        if [ \"\$BDA_TASK_STATUS\" = \"C\" ]">>$THREAD_CMD
  echo "        then">>$THREAD_CMD
  echo "          TASK_MSG=\"BDA operation completed successfully.\"">>$THREAD_CMD
  echo "          TASK_STATUS=1">>$THREAD_CMD
  echo "        elif [ \"\$BDA_TASK_STATUS\" = \"W\" ]">>$THREAD_CMD
  echo "        then">>$THREAD_CMD
  echo "          TASK_MSG=\"BDA operation completed with warnings.\"">>$THREAD_CMD
  echo "          TASK_STATUS=-1">>$THREAD_CMD
  echo "        else">>$THREAD_CMD
  echo "          TASK_MSG=\"BDA operation failed.\"">>$THREAD_CMD
  echo "          TASK_STATUS=-2">>$THREAD_CMD
  echo "        fi">>$THREAD_CMD
  echo "        break">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      sleep 1s">>$THREAD_CMD
  echo "      BDA_AUTH_HMAC=\`printf '%s\\000%s' \"\$BDA_TASK_URL/\$BDA_TASK_RUN_KEY\" \"\" | openssl dgst -sha256 -hmac \"\$BDA_SECRET\" -binary | openssl enc -base64\`">>$THREAD_CMD
  echo "      BDA_AUTH_HEADER=\"Authorization: WSL-SharedSecret-v1 SecretType=Metadata, SecretId=\$BDA_SECRET_ID, HMAC=\\\"\$BDA_AUTH_HMAC\\\"\"">>$THREAD_CMD
  echo "      BDA_TASK_RESPONSE=\`curl -s -S -i -H\"Accept: application/json\" -H\"\$BDA_AUTH_HEADER\" \"\$BDA_TASK_URL/\$BDA_TASK_RUN_KEY\" 2>&1\`">>$THREAD_CMD
  echo "      BDA_TASK_CURL_STATUS_CODE=\"\$?\"">>$THREAD_CMD
  echo "    done">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\$RET_CODE\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned an 18 (remote object) report an error
  # as remote object are not implemented for Unix/Linux schedulers
  #
  echo "elif [ \"\$RET_CODE\" = \"18\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -9 | head -1\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -3 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  echo \"Loads for remote objects can't be executed in the Unix/Linux scheduler.\"">>$THREAD_CMD
  echo "  TASK_MSG=\"Loads for remote objects can't be executed in the Unix/Linux scheduler.\"">>$THREAD_CMD
  echo "  TASK_STATUS=-2">>$THREAD_CMD
  echo "  ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "  bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 98 from ws_job_exec_nnn which indicates a procedure call
  #
  echo "  elif [ \"\$RET_CODE\" = \"98\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    PROC_STMT=\`echo \"\$RES1\" | head -\$LINE | tail -1 | head -1\`">>$THREAD_CMD
  #DEBUG echo "  echo JOB_KEY: \$JOB_KEY">>$THREAD_CMD
  #DEBUG echo "  echo TASK_KEY: \$TASK_KEY">>$THREAD_CMD
  #DEBUG echo "  echo PROC_STMT: \$PROC_STMT">>$THREAD_CMD
  echo "    echo Calling Procedure: \"\$PROC_STMT\"">>$THREAD_CMD
  #
  # Execute a Teradata command to run the stored procedure.
  #
  echo "    RES1=\`bteq <<WSLE01EOF 2>&1">>$THREAD_CMD
  echo "    .logon \${DSS_BTEQDB}/\${JUSER},\${JPWD}">>$THREAD_CMD
  echo "    .set width 254 ">>$THREAD_CMD
  echo "    .set foldline on 1,2 ">>$THREAD_CMD
  echo "    \$PROC_STMT ">>$THREAD_CMD
  echo "     .exit ">>$THREAD_CMD
  echo "WSLE01EOF\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    LINE=\`echo \"\$RES1\" | grep -n \"p_return_msg\" | cut -d: -f1\`">>$THREAD_CMD
  echo "    if [ -z \"\$LINE\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      LINE=\`echo \"\$RES1\" | grep -n \"Failure\" | cut -d: -f1\`">>$THREAD_CMD
  echo "      if [ -z \"\$LINE\" ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        TASK_MSG=\"\"">>$THREAD_CMD
  echo "      else">>$THREAD_CMD
  echo "        TASK_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -1 | head -1 \`">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      TASK_STATUS=-3">>$THREAD_CMD
  echo "    else">>$THREAD_CMD
  echo "      let LINE=\"\$LINE + 5\"">>$THREAD_CMD
  echo "      TASK_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -2 | head -1 \`">>$THREAD_CMD
  echo "      TASK_STATUS=\`echo \"\$RES1\" | head -\$LINE | tail -1 | head -1  \`">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    if [ -z \"\$TASK_MSG\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      TASK_MSG=\"Unknown Call failure see logs\"">>$THREAD_CMD
  echo "      echo Called Procedure Error: \"\$RES1\"">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    ACTION=\"PROCJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #DEBUG echo "echo \"RES  =  \$RES1\"">>$THREAD_CMD
  #DEBUG echo "echo \"LINE =  \$LINE\"">>$THREAD_CMD
  #DEBUG echo "echo \"TASK_MSG  =  \$TASK_MSG\"">>$THREAD_CMD
  #
  # Here if we returned a 99 from ws_job_exec_nnn which indicates a sleep required
  #
  echo "  elif [ \"\$RET_CODE\" = \"99\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_MSG=\"Sleeping \"">>$THREAD_CMD
  echo "    TASK_STATUS=1">>$THREAD_CMD
  echo "    ACTION=\"SLEEP\"">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # Execute a Teradata command to get job wait length
  #
  echo "    RES1=\`bteq <<WSL600SEOFS 2>&1">>$THREAD_CMD
  echo "    .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "    Select '~',coalesce(wjr_idle_thread_wait,30),'~' ">>$THREAD_CMD
  echo "    From $DSS_METABASE.ws_wrk_job_run ">>$THREAD_CMD
  echo "    Where wjr_job_key = \$JOB_KEY ">>$THREAD_CMD
  echo "    And wjr_sequence = \$SEQ; ">>$THREAD_CMD
  echo "    .exit ">>$THREAD_CMD
  echo "WSL600SEOFS\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  echo "    RES2=\$?" >>$THREAD_CMD
  echo "    if [ \"\$RES2\" -ne \"0\" ] && [ \"\$RES2\" -ne \"1\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "       echo \"Teradata returned a non standard return code from the BTEQ of \$RES2\"">>$THREAD_CMD
  echo "       echo \"\$RES1\"">>$THREAD_CMD
  echo "       echo \"Aborting Job ....\"">>$THREAD_CMD
  echo "       exit 23">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD

  # Check warnings in the BTEQ command with exit 0
  echo "    ##" >>$THREAD_CMD
  echo "    # Check for explicit warning text as BTEQ exits with 0" >>$THREAD_CMD
  echo "    ##" >>$THREAD_CMD
  echo "    BTEQ_WARNING=`echo "$RES1" | awk '{ if ($0 ~ /Warning/) print $0}'`" >>$THREAD_CMD
  echo "    if [ \"\$BTEQ_WARNING\" \!\= \"\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      echo \"Teradata returned with warnings from the BTEQ of \$RES2\"">>$THREAD_CMD
  echo "      echo \"\$RES1\"">>$THREAD_CMD
  echo "      echo \"Continuing Job ....\"">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD

  #
  echo "    RES=\`echo \$RES1| sed \"s/ ~ /~/g\"\`">>$THREAD_CMD
  #
  # Extract the job wait interval and sleep
  #
  echo "    #">>$THREAD_CMD
  echo "    SLEEP_DURATION=\`echo \$RES | cut -d \"~\" -f6\`">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  echo "    sleep \$SLEEP_DURATION">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 100 from ws_job_exec_nnn which indicates a BTEQ script
  #
  echo "  elif [ \"\$RET_CODE\" = \"100\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    PROC_STMT=\`echo \"\$RES1\" | head -\$LINE | tail -1 | head -1\`">>$THREAD_CMD
  #DEBUG echo "  echo JOB_KEY: \$JOB_KEY">>$THREAD_CMD
  #DEBUG echo "  echo TASK_KEY: \$TASK_KEY">>$THREAD_CMD
  #DEBUG echo "  echo PROC_STMT: \$PROC_STMT">>$THREAD_CMD
  echo "    echo Calling Procedure: \"\$PROC_STMT\"">>$THREAD_CMD
  #
  # BTEQ script so create a unique script, audit file and error file name
  # which will be located in the work directory as defined in the connection
  # for the load table or script that generated this script.
  #
  echo "    #">>$THREAD_CMD
  echo "    # create a unique name for our script, audit and error trail">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    THREAD_BASE=\"\${EXE_DIR}/wsl\${SEQ}j\${JOB_KEY}t\${TASK_KEY}\"">>$THREAD_CMD
  echo "    THREAD_BTEQ=\"\$THREAD_BASE.bteq\"">>$THREAD_CMD
  echo "    echo \"BTEQ Script \$THREAD_BTEQ\"">>$THREAD_CMD
  echo "    # Get the actual script">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # Get the script itself into the unique script file
  # from the ws_wrk_task_scr_line table
  #
  echo "    rm -f \$THREAD_BTEQ ">>$THREAD_CMD
  echo "    RES1=\`bteq <<WSL600BTEQ 2>&1">>$THREAD_CMD
  echo "    .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD}">>$THREAD_CMD
  echo "    .export report file=\$THREAD_BTEQ ">>$THREAD_CMD
  echo "    Select wtsl_line (TITLE '') ">>$THREAD_CMD
  echo "    From $DSS_METABASE.ws_wrk_task_scr_line ">>$THREAD_CMD
  echo "    Where wtsl_job_key = \$JOB_KEY ">>$THREAD_CMD
  echo "    And wtsl_task_key = \$TASK_KEY ">>$THREAD_CMD
  echo "    And wtsl_sequence = \$SEQ ">>$THREAD_CMD
  echo "    Order by wtsl_line_no; ">>$THREAD_CMD
  echo "    .exit ">>$THREAD_CMD
  echo "WSL600BTEQ\`">>$THREAD_CMD
  echo "    RES=\`echo \"\$RES1\" | sed \"s/ ~ /~/g\"\`">>$THREAD_CMD
  #
  # Run BTEQ script
  #
  echo "    RES1=\`bteq .logon \${DSS_BTEQDB}/\${DSS_USER},\${DSS_PWD} <\$THREAD_BTEQ 2>&1\`" >> $THREAD_CMD

  echo "    #">>$THREAD_CMD
  echo "    LINE=\`echo \"\$RES1\" | grep -n \"Insert completed. \" \`">>$THREAD_CMD
  echo "    if [ -z \"\$LINE\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      TASK_MSG=\`echo \"\$RES1\" | grep -n \"Failure\" \`">>$THREAD_CMD
  echo "      TASK_STATUS=-3">>$THREAD_CMD
  echo "    else">>$THREAD_CMD
  echo "      TASK_MSG=\`echo \"\$LINE\" | cut -d\".\" -f2 \`">>$THREAD_CMD
  echo "      TASK_STATUS=1">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    if [ -z \"\$TASK_MSG\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      TASK_MSG=\"Unknown Call failure see logs\"">>$THREAD_CMD
  echo "      echo Called Procedure Error: \"\$RES1\"">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  #DEBUG echo "echo \"RES  =  \$RES1\"">>$THREAD_CMD
  #DEBUG echo "echo \"LINE =  \$LINE\"">>$THREAD_CMD
  #DEBUG echo "echo \"TASK_MSG  =  \$TASK_MSG\"">>$THREAD_CMD
  #
  # Here if we returned a -1 from ws_job_exec_nnn which indicates a warning completion
  # May need to PAGE or MAIL if the action is set.
  #
  echo "  elif [ \"\$RET_CODE\" = \"-1\" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    echo \"Warning completion\"">>$THREAD_CMD
  echo "    bMORE=\"N\"">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  #
  # Here if we returned a an error from ws_job_exec_nnn which indicates a failure
  # May need to PAGE or MAIL if the action is set.
  #
  echo "  else">>$THREAD_CMD
  echo "    echo \"\$RES\"">>$THREAD_CMD
  echo "    echo \"Error completion\"">>$THREAD_CMD
  echo "    bMORE=\"N\"">>$THREAD_CMD
  echo "    JOB_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -8 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \"\$RES1\" | head -\$LINE | tail -7 | head -1\`">>$THREAD_CMD
  echo "    TASK_NAME=\`echo \$TASK_NAME\`">>$THREAD_CMD
  echo "    TASK_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -6 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_KEY=\`echo \"\$RES1\" | head -\$LINE | tail -5 | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    ACTION_MSG=\`echo \"\$RES1\" | head -\$LINE | tail -4 | head -1\`">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD
  echo "done">>$THREAD_CMD
  #
  # Call the ws_job_exec_411 has completed
  # now check to see if we have a command to run
  #
  echo "echo \"\$ACTION_KEY \$ACTION_MSG\"">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "if [ \"\$ACTION_KEY\" = \"1\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  sh -c \"\$ACTION_MSG\"">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "if [ \"\$ACTION_KEY\" = \"2\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  sh -c \"\$ACTION_MSG\"">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  # Finished the create of the script the thread will run
  # so set it to an executable and
  # Run it in background
  #
  chmod 750 $THREAD_CMD
  nohup $THREAD_CMD >$THREAD_LOG 2>&1 &
done
exit
