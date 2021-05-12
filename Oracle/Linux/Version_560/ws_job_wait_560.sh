#!/bin/sh
#
# <<< IMPORTANT NOTICE: Please do not modify this software as doing so could cause support issues and result in additional support fees being charged.
#
# ============================================================================
# DBMS Name     : Oracle
# Script Name   : ws_job_wait_560.sh
# Description   : Initiates the threads of a job that is ready
# Author        : Wayne Richmond
# Date          : Version 6.8.6.3 10/10/2016
# WhereScape Limited, inc. All Rights Reserved. (C)Copyright 2002-2019
# =============================================================================
# Notes / History
#
# Positional parameters are 1 = oraenv file name, 2 = scheduler name
#
# WMR 25/02/2002                  Changed method of recording audit and error messages due
#                 Version 1.0.1   to problems on IBM platform. Now 1 line at a time
# WMR 01/03/2002                  Added additional debug messages when a failure occurs
# WMR 05/04/2002  Version 1.0.7   Scheduler selection support
# WMR 05/04/2002  Version 1.0.7.1 Produce failure if ODBC jobs attempted
# WMR 12/10/2002  Version 1.2.1.3 Changed EOF to WSL010EOF to avoid conflict
#                                 with user written scripts
# WMR 22/04/2003  Version 1.2.1.7 Handle single quotes in result message
#                                 and ensure numeric task status
# WMR 15/08/2003  Version 4.1.0   Put variables in oraenv.
# WMR 28/11/2003                  Changed job name to WSLnnnn_xx_job, nnn=sequence, xx=thread
# WMR 01/09/2004  Version 4.1.0.7 Put job name, task_name, job_key, task_key, seq
#                                 in as positional parameters in the executed script
# WMR 01/03/2005  Version 4.1.1.3 Now call Ws_Job_Exec_411 to handle jobs within jobs
# JML 17/04/2007  Version 5.6.0.0 Added support for export objects
# RS  26/11/2013  Version 6.7.1.3 Fixed issue: schedulers fail to run success
#                                 and failure commands if "completed" is in command
# HM  17/09/2014  Version 6.8.1.2 Fixed issue: if AUD file starts with empty lines
#                                 end result is not reported correctly
# HM  02/03/2015  Version 6.8.3.2 Add support for Hadoop scripts
# HM  15/04/2015  Version 6.8.4.0 RED-4867: Export SEQ and THREAD; add and export RESTART_COUNT.
# BC  11/02/2016  Version 6.8.5.3 Added support for BDA Server operations
# TA  26/02/2016  Version 6.8.5.3 Added support for BDA Server authentication
# RS  21/03/2016  Version 6.8.5.3 Added error handling for remote objects
# BC  30/03/2016  Version 6.8.5.4 RED-881 Support added to execute Failure Command when job
#                                  fails due to job dependency failure.
# HM  12/10/2016  Version 6.8.6.3 Added warning that on-the-fly template Create DDL isn't supported.
# BC  21/11/2016  Version 6.8.6.3 RED-7329 Initialise new environment variables for Script-based loads and exports.
# BC  27/01/2017  Version 6.8.7.0 RED-7740 Initialise new environment variables for standalone Script executions.
# BC  25/10/2017  Version 8.1.1.0 RED-8904 Fixed a query to not use a subquery in an outer join condition.
# TA  23/11/2018  Version 8.3.1.0 RED-9957 Support arbitrary script interpreters
# HM  22/02/2019  Version 8.4.1.0 RED-7407 Increase max length of success/failure command.
# ============================================================================
# SETTINGS
#
ORAENV=$HOME/$1
RUNSHELL=sh
# ============================================================================
. $ORAENV

#
# Note: acquire the job exe directory from the oraenv file if set.
if [ "$JOB_EXE_DIR" = "" ]
then
  EXE_DIR=$HOME/wsl/sched/job
else
  EXE_DIR=$JOB_EXE_DIR
fi
# Note: acquire the job log directory from the oraenv file if set.
if [ "$JOB_LOG_DIR" = "" ]
then
  LOG_DIR=$HOME/wsl/sched/joblog
else
  LOG_DIR=$JOB_LOG_DIR
fi

##
# Issue a sqlplus command to get the next job to run
# Result will be 2 if no jobs to run
# or 1 if there is a job ready
##

RES=`sqlplus -s <<WSL010EOF| grep -v "completed" | grep -v "^$" | tr -s "\n" "~"
$DSS_USER/$DSS_PWD
set sqlprompt "";
set heading off;
set pagesize 0
set linesize 256
set trimspool on
set echo off;
variable x number;
variable task varchar2(64);
variable job varchar2(64);
variable restart varchar2(12);
variable sequence number;
variable threads number;
variable command varchar2(12);
exec :x := ws_job_wait('UNIX','$2',:job, :task, :restart, :threads, :sequence);
print :x :job :task :restart :threads :sequence;
exit;
WSL010EOF`

##
# Check that the sqlplus command worked.
# Often when sqlplus fails with an Oracle error it will echo
# the start of the command so we will see BEGIN... returned
# If a failure then exit with a failure to force the scheduler to stop
# This prevents recursive errors every 30 seconds
#
if [ "$?" -ne "0" ]
then
   echo "Sql*Plus returned a non standard return code of $?"
   echo "$RES"
   echo "Aborting Scheduler...."
   exit 23
fi
RET_CHECK=`echo $RES | cut -d " " -f1`
if [ "$RET_CHECK" = "BEGIN" ]
then
   echo "Sql*Plus failed with an oracle error. See logs"
   echo "$RES"
   echo "Aborting Scheduler...."
   exit 24
fi

#
# Get the return status
# If a negative then we have a problem
# If 2 then no jobs so quit.
# if 5 then asked to do a status
# if 9 then asked to shutdown
#
RET_CODE=`echo $RES | cut -d "~" -f1`
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
  JOB_NAME=`echo $RES | cut -d "~" -f2`
  JOB_SEQ=`echo $RES | cut -d "~" -f6 | tr -d ' '`
  JOB_THREAD=0
  echo Job dependency failure for $JOB_NAME $JOB_SEQ
  RES=`sqlplus -s <<WSL010EOF | sed "s/~/WSLTILDE/g" | sed "s/WSLDELIM/~/g"
    $DSS_USER/$DSS_PWD
    set sqlprompt "";
    set heading off;
    set pagesize 0;
    set linesize 256;
    set trimspool on;
    set echo off;
    SELECT 'WSLDELIM' || wjr_job_key AS job_key, 'WSLDELIM' || wjr_publish_fail AS fail_cmd, 'WSLDELIM' AS rec_delim FROM ws_wrk_job_run WHERE RTRIM(UPPER(wjr_name)) = RTRIM(UPPER('$JOB_NAME'));
    exit;
WSL010EOF`
  JOB_KEY=`echo $RES | cut -d "~" -f2 | tr -d " "`
  ACT_MSG=`echo $RES | cut -d "~" -f3 | sed "s/WSLTILDE/~/g" | sed "s/[$]JOB_NAME[$]/$JOB_NAME/g" | sed "s/[$]JOB_KEY[$]/$JOB_KEY/g" | sed "s/[$]JOB_SEQ[$]/$JOB_SEQ/g" | sed "s/[$]JOB_THREAD[$]/$JOB_THREAD/g" | sed "s/'/''/g"`
  RES=`sqlplus -s <<WSL010EOF | grep -v "completed" | grep -v "^$"
    $DSS_USER/$DSS_PWD
    set sqlprompt "";
    set heading off;
    set pagesize 0;
    set linesize 256;
    set trimspool on;
    set echo off;
    variable new_str varchar2(4000);
    exec :new_str := WsParameterReplace('$ACT_MSG',4000);
    print :new_str
    exit;
WSL010EOF`
  ACT_MSG=`echo $RES`
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
  echo "$RES"
  exit 25
fi

#
# Set up all our parameter variables
#
JOB=`echo $RES | cut -d "~" -f2`
TASK=`echo $RES | cut -d "~" -f3`
FLAG=`echo $RES | cut -d "~" -f4`
THREADS=`echo $RES | cut -d "~" -f5 | tr -d ' '`
SEQ=`echo $RES | cut -d "~" -f6 | tr -d ' '`

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
  echo $THREAD_CMD
  #
  # Populate the thread shell command file
  # set default variables
  #
  echo "#!/bin/$RUNSHELL">$THREAD_CMD
  echo ". $HOME/$1">>$THREAD_CMD
  echo "JOB_NAME=\"$JOB\"">>$THREAD_CMD
  echo "MASTER_JOB_NAME=\"$JOB\"">>$THREAD_CMD
  echo "TASK_NAME=\"$TASK\"">>$THREAD_CMD
  echo "ACTION=\"$FLAG\"">>$THREAD_CMD
  echo "export THREAD=$i">>$THREAD_CMD
  echo "export SEQ=$SEQ">>$THREAD_CMD
  echo "JOB_KEY=0">>$THREAD_CMD
  echo "MASTER_JOB_KEY=0">>$THREAD_CMD
  echo "TASK_KEY=0">>$THREAD_CMD
  echo "TASK_STATUS=0">>$THREAD_CMD
  echo "TASK_MSG=\"\"">>$THREAD_CMD
  echo "LOG_DIR=$LOG_DIR">>$THREAD_CMD
  echo "EXE_DIR=$EXE_DIR">>$THREAD_CMD
  echo "REJOIN_JOB_LIST=\"\"">>$THREAD_CMD
  echo "REJOIN_TASK_LIST=\"\"">>$THREAD_CMD
  echo "bMORE=\"Y\"">>$THREAD_CMD
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
  # Execute the ws-job_exec_nnn procedure.
  #
  echo "TASK_MSG=\`echo \$TASK_MSG | sed \"s/'/''/g\"\`">>$THREAD_CMD
  echo "RES=\`sqlplus -s <<WSL010EOF1 | grep -v \"^$\" | tr -s \"\\012\" \"~\"">>$THREAD_CMD
  echo "$DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "set sqlprompt \"\";">>$THREAD_CMD
  echo "set heading off;">>$THREAD_CMD
  echo "set pagesize 0;">>$THREAD_CMD
  echo "set linesize 4000;">>$THREAD_CMD
  echo "set trimspool on;">>$THREAD_CMD
  echo "set feedback off;">>$THREAD_CMD
  echo "set echo off;">>$THREAD_CMD
  echo "variable result_code number;">>$THREAD_CMD
  echo "variable result_msg varchar2(256);">>$THREAD_CMD
  echo "variable job_key number;">>$THREAD_CMD
  echo "variable task_key number;">>$THREAD_CMD
  echo "variable task_name varchar2(64);">>$THREAD_CMD
  echo "variable action_key number;">>$THREAD_CMD
  echo "variable action_msg varchar2(4000);">>$THREAD_CMD
  echo "variable Job_key_list varchar2(256);">>$THREAD_CMD
  echo "variable task_key_list varchar2(256);">>$THREAD_CMD
  echo "variable task_data varchar2(4000);">>$THREAD_CMD
  echo "exec ws_job_exec_411('\$JOB_NAME','\$TASK_NAME','\$ACTION',\$THREAD,\$SEQ,\$JOB_KEY,\$TASK_KEY,\$TASK_STATUS,'\$TASK_MSG','\$MASTER_JOB_NAME',\$MASTER_JOB_KEY,'\$REJOIN_JOB_LIST','\$REJOIN_TASK_LIST',:result_code, :result_msg, :job_key,:task_key, :task_name, :action_key,:action_msg,:job_key_list,:task_key_list,:task_data);">>$THREAD_CMD
  echo "print :result_code;">>$THREAD_CMD
  echo "print :result_msg;">>$THREAD_CMD
  echo "print :job_key;">>$THREAD_CMD
  echo "print :task_key;">>$THREAD_CMD
  echo "print :task_name;">>$THREAD_CMD
  echo "print :action_key;">>$THREAD_CMD
  echo "print :action_msg;">>$THREAD_CMD
  echo "print :job_key_list;">>$THREAD_CMD
  echo "print :task_key_list;">>$THREAD_CMD
  echo "print :task_data;">>$THREAD_CMD
  echo "exit;">>$THREAD_CMD
  echo "WSL010EOF1\`">>$THREAD_CMD
  #
  # Get the results from the sqlplus command and make
  # sure it worked else report an error and abort the thread
  #
  echo "#">>$THREAD_CMD
  echo "# Set up all our parameter variables">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "if [ \"\$?\" -ne \"0\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "   echo \"Sql*Plus returned a non standard return code of \$?\"">>$THREAD_CMD
  echo "   echo \"\$RES\"">>$THREAD_CMD
  echo "   echo \"Aborting Job ....\"">>$THREAD_CMD
  echo "   exit 23">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  echo "RET_CHECK=\`echo \$RES | cut -d \" \" -f1\`">>$THREAD_CMD
  echo "if [ \"\$RET_CHECK\" = \"BEGIN\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "   echo \"Sql*Plus failed with an oracle error. See logs\"">>$THREAD_CMD
  echo "   echo \"\$RES\"">>$THREAD_CMD
  echo "   echo \"Aborting Job....\"">>$THREAD_CMD
  echo "   exit -1">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  #
  # Sqlplus worked. So now we need to see if the job worked, failed
  # or wishes to run a breakout script
  #
  echo "# Get the return status">>$THREAD_CMD
  echo "# If a negative then we have a job warning, error or failure">>$THREAD_CMD
  echo "# If 2 then a script to run.">>$THREAD_CMD
  echo "# If 1 then all okay">>$THREAD_CMD
  echo "#">>$THREAD_CMD
  echo "RET_CODE=\`echo \$RES | cut -d \"~\" -f1\`">>$THREAD_CMD
  echo "if [ \"\$RET_CODE\" = "1" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  #
  # Code below if we have finished and it was successful
  #
  echo "  echo \"Normal Completion\"">>$THREAD_CMD
  echo "  bMORE=\"N\"">>$THREAD_CMD
  echo "  echo \"\$RES\"">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "elif [ \"\$RET_CODE\" = \"2\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  #
  # Code below if a breakout script is required.
  # the script is loaded into the table ws_wrk_task_scr_line
  # and a header table exists providing information such as
  # the host platform etc.
  #
  # Get the information returned from ws_job_exec_nnn which is
  # the job and task keys
  #
  echo "  echo \"Script Called\"">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \$RES | cut -d \"~\" -f2\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  MASTER_JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \$RES | cut -d \"~\" -f4 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \$RES | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \$RES | cut -d \"~\" -f8\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \$RES | cut -d \"~\" -f9\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  # Break out the returned variables">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  # Get the information from the script header file">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  #
  # Execute a sqlplus command to get information from the header
  # table about the script we are to run
  #
  echo "  RES=\`sqlplus -s <<WSL010EOF2 | grep -v \"rows selected.$\" | grep -v \"^$\" | tr -d \"\\015\" | tr -s \"\\012\" \",\" ">>$THREAD_CMD
  echo "  \$DSS_USER/\$DSS_PWD">>$THREAD_CMD
  echo "  set sqlprompt \"\";">>$THREAD_CMD
  echo "  set heading off;">>$THREAD_CMD
  echo "  set pagesize 0;">>$THREAD_CMD
  echo "  set linesize 256;">>$THREAD_CMD
  echo "  set trimspool on;">>$THREAD_CMD
  echo "  set echo off;">>$THREAD_CMD
  echo "  Select nvl(wtsh_host_type,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_work_dir,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_script_type,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_load_type,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_script_key,0)||','||">>$THREAD_CMD
  echo "         nvl(wtsh_load_key,0)||','||">>$THREAD_CMD
  echo "         nvl(wtsh_connect_key,0)||','||">>$THREAD_CMD
  echo "         nvl(wjr_restart,0)||','||">>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "                 THEN SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "                                                                                                                                          LENGTH(src.dc_authentication)),';')," >>$THREAD_CMD
  echo "                                                         CASE WHEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') > 0" >>$THREAD_CMD
  echo "                                                              THEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') - 1" >>$THREAD_CMD
  echo "                                                              ELSE LENGTH(src.dc_authentication)" >>$THREAD_CMD
  echo "                                                         END)" >>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END||' ,'||" >>$THREAD_CMD
  echo "                      nvl(src.dc_extract_userid,' ')||','||" >>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "               THEN SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "                                                                                                                                          LENGTH(src.dc_authentication)),';'),">>$THREAD_CMD
  echo "                                                         CASE WHEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') > 0">>$THREAD_CMD
  echo "                                                              THEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') - 1">>$THREAD_CMD
  echo "                                                              ELSE LENGTH(src.dc_authentication)">>$THREAD_CMD
  echo "                                                         END)">>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END||' ,'||" >>$THREAD_CMD
  echo "                      nvl(src.dc_extract_pwd,' ')||','||" >>$THREAD_CMD
  echo "         CASE WHEN tgt.dc_authentication like '%TDWalletUser~=%' AND tgt.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "                 THEN SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "                                                                                                                                          LENGTH(tgt.dc_authentication)),';')," >>$THREAD_CMD
  echo "                                                         CASE WHEN INSTR( SUBSTR(tgt.dc_authentication,  INSTR(tgt.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(tgt.dc_authentication)),';'), 100),';') > 0" >>$THREAD_CMD
  echo "                                                              THEN INSTR( SUBSTR(tgt.dc_authentication,  INSTR(tgt.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(tgt.dc_authentication)),';'), 100),';') - 1" >>$THREAD_CMD
  echo "                                                              ELSE LENGTH(tgt.dc_authentication)" >>$THREAD_CMD
  echo "                                                         END)" >>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END||' ,'||" >>$THREAD_CMD
  echo "                      nvl(tgt.dc_extract_userid,' ')||','||" >>$THREAD_CMD
  echo "         CASE WHEN tgt.dc_authentication like '%TDWalletUser~=%' AND tgt.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "               THEN SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "                                                                                                                                          LENGTH(tgt.dc_authentication)),';'),">>$THREAD_CMD
  echo "                                                         CASE WHEN INSTR( SUBSTR(tgt.dc_authentication,  INSTR(tgt.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(tgt.dc_authentication)),';'), 100),';') > 0">>$THREAD_CMD
  echo "                                                              THEN INSTR( SUBSTR(tgt.dc_authentication,  INSTR(tgt.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(tgt.dc_authentication, INSTR(tgt.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(tgt.dc_authentication)),';'), 100),';') - 1">>$THREAD_CMD
  echo "                                                              ELSE LENGTH(tgt.dc_authentication)">>$THREAD_CMD
  echo "                                                         END)">>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END||' ,'||" >>$THREAD_CMD
  echo "                      nvl(tgt.dc_extract_pwd,' ')||',' DATA_STREAM " >>$THREAD_CMD
  echo "  From ws_wrk_task_scr_hdr">>$THREAD_CMD
  echo "  Left Outer Join ws_wrk_job_run On wtsh_job_key = wjr_job_key">>$THREAD_CMD
  echo "  Left Outer Join ws_load_tab On lt_obj_key = wtsh_load_key ">>$THREAD_CMD
  echo "  Left Outer Join ws_dbc_connect src On src.dc_obj_key = (Case When lt_obj_key Is Not Null Then lt_connect_key Else wtsh_connect_key End) ">>$THREAD_CMD
  echo "  Left Outer Join ws_obj_object On lt_obj_key = oo_obj_key ">>$THREAD_CMD
  echo "  Left Outer Join ws_dbc_target On oo_target_key = dt_target_key ">>$THREAD_CMD
  echo "  Left Outer Join ws_dbc_connect tgt ">>$THREAD_CMD
  echo "    On (lt_obj_key Is Not Null And ((oo_target_key <> 0 And dt_connect_key = tgt.dc_obj_key) Or (oo_target_key = 0 And tgt.dc_attributes LIKE '%DataWarehouse;%'))) ">>$THREAD_CMD
  echo "    Or (lt_obj_key Is Null And tgt.dc_obj_key = wtsh_connect_key) ">>$THREAD_CMD
  echo "  Where wtsh_job_key = \$JOB_KEY">>$THREAD_CMD
  echo "  And wtsh_task_key = \$TASK_KEY">>$THREAD_CMD
  echo "  And wtsh_sequence = \$SEQ;">>$THREAD_CMD
  echo "  exit;">>$THREAD_CMD
  echo "WSL010EOF2\`">>$THREAD_CMD
  #
  # Get all the information stored in the header table
  # Check that this is a Unix script.
  # If not Unix then unsupported.
  #
  echo "  #">>$THREAD_CMD
  echo "  # See what type of script we have">>$THREAD_CMD
  echo "  # If not a Unix script then not supported">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  echo \"\$RES\"">>$THREAD_CMD
  echo "  HOST_TYPE=\`echo \$RES | cut -d \",\" -f1\`">>$THREAD_CMD
  echo "  WORK_DIR=\`echo \$RES | cut -d \",\" -f2\`">>$THREAD_CMD
  echo "  SCRIPT_TYPE=\`echo \$RES | cut -d \",\" -f3\`">>$THREAD_CMD
  echo "  LOAD_TYPE=\`echo \$RES | cut -d \",\" -f4\`">>$THREAD_CMD
  echo "  SCRIPT_KEY=\`echo \$RES | cut -d \",\" -f5 | tr -d \" \"\`">>$THREAD_CMD
  echo "  LOAD_KEY=\`echo \$RES | cut -d \",\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  CONNECT_KEY=\`echo \$RES | cut -d \",\" -f7 | tr -d \" \"\`">>$THREAD_CMD
  echo "  RESTART_COUNT=\`echo \$RES | cut -d \",\" -f8 | tr -d \" \"\`; export RESTART_COUNT">>$THREAD_CMD

  echo "   SRC_USER=\`echo \$RES | cut -d \",\" -f9 | tr -d \" \"\`; export SRC_USER">>$THREAD_CMD
  # If Wallet user is set then use it, else revert to use the std extract user
  echo "   if [ \"\$SRC_USER\" \!\= \"\" ] ">>$THREAD_CMD
  echo "   then">>$THREAD_CMD
  echo "     SRC_PWD=\`echo \$RES | cut -d \",\" -f11 | tr -d \" \"\`">>$THREAD_CMD
  echo "     SRC_PWD=\\\$tdwallet\(\$SRC_PWD\); export SRC_PWD">>$THREAD_CMD
  echo "   else">>$THREAD_CMD
  echo "     SRC_USER=\`echo \$RES | cut -d \",\" -f10 | tr -d \" \"\`; export SRC_USER">>$THREAD_CMD
  echo "     SRC_PWD=\`echo \$RES | cut -d \",\" -f12 | tr -d \" \"\`; export SRC_PWD">>$THREAD_CMD
  echo "   fi">>$THREAD_CMD

  echo "   TGT_USER=\`echo \$RES | cut -d \",\" -f13 | tr -d \" \"\`; export TGT_USER">>$THREAD_CMD
  # If Wallet user is set then use it, else revert to use the std extract user
  echo "   if [ \"\$TGT_USER\" \!\= \"\" ] ">>$THREAD_CMD
  echo "   then">>$THREAD_CMD
  echo "     TGT_PWD=\`echo \$RES | cut -d \",\" -f15 | tr -d \" \"\`">>$THREAD_CMD
  echo "     TGT_PWD=\\\$tdwallet\(\$TGT_PWD\); export TGT_PWD">>$THREAD_CMD
  echo "   else">>$THREAD_CMD
  echo "     TGT_USER=\`echo \$RES | cut -d \",\" -f14 | tr -d \" \"\`; export TGT_USER">>$THREAD_CMD
  echo "     TGT_PWD=\`echo \$RES | cut -d \",\" -f16 | tr -d \" \"\`; export TGT_PWD">>$THREAD_CMD
  echo "   fi">>$THREAD_CMD

  echo "   META_USER=\${META_USER-\${DSS_USER}}; export META_USER">>$THREAD_CMD
  echo "   META_PWD=\${META_PWD-\${DSS_PWD}}; export META_PWD">>$THREAD_CMD

  echo "  #">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  #
  # Not Unix so not supported. We will process through the loop
  # again to pass the unsupported message back to the scheduler.
  #
  echo "  if [ \"\$HOST_TYPE\" != "U" ] && [ \"\$HOST_TYPE\" != "H" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    echo \"Unix scheduler does not support Non Unix loads and scripts\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Unix scheduler does not support Non Unix loads and scripts \$HOST_TYPE \"">>$THREAD_CMD
  echo "    TASK_STATUS=-2">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  echo "  else">>$THREAD_CMD
  #
  # Unix script so create a unique script, audit file and error file name
  # which will be located in the work directory as defined in the connection
  # for the load table or script that generated this script.
  #
  echo "    #">>$THREAD_CMD
  echo "    # create a unique name for our script, audit and error trail">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    THREAD_BASE=\"\${WORK_DIR}wsl\${SEQ}j\${JOB_KEY}t\${TASK_KEY}\"">>$THREAD_CMD
  echo "    THREAD_SH=\"\$THREAD_BASE.sh\"">>$THREAD_CMD
  echo "    THREAD_SCRIPT=\"\$THREAD_BASE.script\"">>$THREAD_CMD
  echo "    THREAD_AUD=\"\$THREAD_BASE.aud\"">>$THREAD_CMD
  echo "    THREAD_ERR=\"\$THREAD_BASE.err\"">>$THREAD_CMD
  echo "    echo \"Script \$THREAD_SH\"">>$THREAD_CMD
  echo "    echo \"Audit \$THREAD_AUD\"">>$THREAD_CMD
  echo "    echo \"Error \$THREAD_ERR\"">>$THREAD_CMD
  echo "    # Get the actual script">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # Get the script itself into the unique script file
  # from the ws_wrk_task_scr_line table
  #
  echo "    sqlplus -s <<WSL010EOF3 | grep -v \"rows selected.$\" | grep -v \"^$\" | tr -d \"\\015\" >\$THREAD_SH">>$THREAD_CMD
  echo "    \$DSS_USER/\$DSS_PWD">>$THREAD_CMD
  echo "    set sqlprompt \"\";">>$THREAD_CMD
  echo "    set heading off;">>$THREAD_CMD
  echo "    set pagesize 0;">>$THREAD_CMD
  echo "    set linesize 256;">>$THREAD_CMD
  echo "    set trimspool on;">>$THREAD_CMD
  echo "    set echo off;">>$THREAD_CMD
  echo "    Select wtsl_line from ws_wrk_task_scr_line">>$THREAD_CMD
  echo "    Where wtsl_job_key = \$JOB_KEY">>$THREAD_CMD
  echo "    And wtsl_task_key = \$TASK_KEY">>$THREAD_CMD
  echo "    And wtsl_sequence = \$SEQ">>$THREAD_CMD
  echo "    Order by wtsl_line_no;">>$THREAD_CMD
  echo "    exit;">>$THREAD_CMD
  echo "WSL010EOF3">>$THREAD_CMD
  #
  # Remove the body of the script from the script file and put it in a
  # separate file that is invoked from the script file. The special token
  # ~~WSL_CUT_HERE~~ tells us where to break the script.
  #
  echo "    CUT_LINE_NO=\`grep -n \"~~WSL_CUT_HERE~~\" \"\$THREAD_SH\" | cut -d: -f1\`">>$THREAD_CMD
  echo "    if [ \"\$CUT_LINE_NO\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      sed \"\$CUT_LINE_NO,\\\$d\" \"\$THREAD_SH\" >\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "      echo \\\"\$THREAD_SCRIPT\\\" >>\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "      sed \"1,\${CUT_LINE_NO}d\" \"\$THREAD_SH\" >\"\$THREAD_SCRIPT\"">>$THREAD_CMD
  echo "      mv \"\$THREAD_SH\".tmp \"\$THREAD_SH\"">>$THREAD_CMD
  echo "      chmod 750 \$THREAD_SCRIPT">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  #
  # Execute the script
  # The standard is that the first row on standard output is the result code
  # being either 1=success, -1=warning, -2=error, -3=fatal error
  # The second row on standard out will be the returned message
  #
  echo "    chmod 750 \$THREAD_SH">>$THREAD_CMD
  echo "    \$THREAD_SH \"\$JOB_NAME\" \"\$TASK_NAME\" \$JOB_KEY \$TASK_KEY \$SEQ >\$THREAD_AUD 2>\$THREAD_ERR">>$THREAD_CMD
  echo "    TASK_STATUS=\`awk 'NF>0' \$THREAD_AUD | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_MSG=\`awk 'NF>0' \$THREAD_AUD | head -2 | tail -1\`">>$THREAD_CMD
  echo "    if [ \"\$TASK_STATUS\" != \"1\" -a \"\$TASK_STATUS\" != \"-1\" -a \"\$TASK_STATUS\" != \"-2\"  -a \"\$TASK_STATUS\" != \"-3\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      TASK_MSG_TMP=\"Invalid return code: \$TASK_STATUS. return_msg: \$TASK_MSG\"">>$THREAD_CMD
  echo "      TASK_MSG=\`echo \$TASK_MSG_TMP | cut -c1-255\`">>$THREAD_CMD
  echo "      TASK_STATUS=-3">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    # Put out any additional rows to the workflow audit trail">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # If there are any additional rows in standard out then write then to
  # the audit trail
  #
  echo "    LIN=\`cat \$THREAD_AUD | wc -l | tr -d \" \"\`">>$THREAD_CMD
  echo "    echo \"\$LIN audit lines\"">>$THREAD_CMD
  echo "    if [ \"\$LIN\" != \"2\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      ROWNUM=0">>$THREAD_CMD
  echo "      while [ \"\$ROWNUM\" -lt \"\$LIN\" ]">>$THREAD_CMD
  echo "      do">>$THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM+1\"">>$THREAD_CMD
  echo "        if [ \"\$ROWNUM\" -gt \"2\" ] ">>$THREAD_CMD
  echo "        then">>$THREAD_CMD
  echo "          AUD_TRAIL=\`cat \$THREAD_AUD |head -\$ROWNUM | tail -1| sed \"s/'/''/g\"\`">>$THREAD_CMD
  echo "          sqlplus -s <<WSL010EOF4">>$THREAD_CMD
  echo "          $DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "          variable x number;">>$THREAD_CMD
  echo "          exec :x := wswrkaudit('I','\$JOB_NAME','\$TASK_NAME',\$SEQ,'\$AUD_TRAIL','','',\$TASK_KEY,\$JOB_KEY);">>$THREAD_CMD
  echo "          exit;">>$THREAD_CMD
  echo "WSL010EOF4">>$THREAD_CMD
  echo "        fi">>$THREAD_CMD
  echo "      done">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  #
  # If any rows in standard error then write them to the error/detail trail
  #
  echo "    LIN=\`cat \$THREAD_ERR | wc -l | tr -d \" \"\`">>$THREAD_CMD
  echo "    echo \"\$LIN error trail lines\"">>$THREAD_CMD
  echo "    if [ \"\$LIN\" != \"0\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      ROWNUM=0">>$THREAD_CMD
  echo "      while [ \"\$ROWNUM\" -lt \"\$LIN\" ]">>$THREAD_CMD
  echo "      do">>$THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM+1\"">>$THREAD_CMD
  echo "        ERR_TRAIL=\`cat \$THREAD_ERR | head -\$ROWNUM | tail -1 | sed \"s/'/''/g\"\`">>$THREAD_CMD
  echo "        sqlplus -s <<WSL010EOF5">>$THREAD_CMD
  echo "        $DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "        variable x number;">>$THREAD_CMD
  echo "        exec :x := wswrkerror('I','\$JOB_NAME','\$TASK_NAME',\$SEQ,'\$ERR_TRAIL','','',\$TASK_KEY,\$JOB_KEY,'');">>$THREAD_CMD
  echo "        exit;">>$THREAD_CMD
  echo "WSL010EOF5">>$THREAD_CMD
  echo "      done">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD
  #
  # Here if we returned a 3 from ws_job_exec_nnn which indicates an ODBC based load
  # Not supported under Unix
  #
  echo "elif [ \"\$RET_CODE\" = \"3\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  echo \"ODBC Load Called\"">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \$RES | cut -d \"~\" -f2\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  MASTER_JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \$RES | cut -d \"~\" -f4 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \$RES | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \$RES | cut -d \"~\" -f8\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \$RES | cut -d \"~\" -f9\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  echo \"Unix scheduler does not support ODBC based load\"">>$THREAD_CMD
  echo "  TASK_MSG=\"Unix scheduler does not support ODBC based loads \$HOST_TYPE \"">>$THREAD_CMD
  echo "  TASK_STATUS=-2">>$THREAD_CMD
  echo "  ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "  bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 4 from ws_job_exec_nnn which indicates a CUBE create
  # Not supported under Unix
  #
  echo "elif [ \"\$RET_CODE\" = \"4\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  echo \"CUBE Create Called\"">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \$RES | cut -d \"~\" -f2\`">>$THREAD_CMD
  echo "  MASTER_JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \$RES | cut -d \"~\" -f4 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \$RES | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \$RES | cut -d \"~\" -f8\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \$RES | cut -d \"~\" -f9\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  echo \"Unix scheduler does not support CUBE creates\"">>$THREAD_CMD
  echo "  TASK_MSG=\"Unix scheduler does not support CUBE creates \$HOST_TYPE \"">>$THREAD_CMD
  echo "  TASK_STATUS=-2">>$THREAD_CMD
  echo "  ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "  bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 5 from ws_job_exec_nnn which indicates a CUBE process
  # Not supported under Unix
  #
  echo "elif [ \"\$RET_CODE\" = \"5\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  echo \"CUBE Process Called\"">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \$RES | cut -d \"~\" -f2\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  MASTER_JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \$RES | cut -d \"~\" -f4 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \$RES | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \$RES | cut -d \"~\" -f8\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \$RES | cut -d \"~\" -f9\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  echo \"Unix scheduler does not support CUBE processing\"">>$THREAD_CMD
  echo "  TASK_MSG=\"Unix scheduler does not support CUBE processing \$HOST_TYPE \"">>$THREAD_CMD
  echo "  TASK_STATUS=-2">>$THREAD_CMD
  echo "  ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "  bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a 11 from ws_job_exec_nnn which indicates an export
  #
  echo "elif [ \"\$RET_CODE\" = \"11\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  #
  # Code below if a breakout script is required for an export.
  # the script is loaded into the table ws_wrk_task_scr_line
  # and a header table exists providing information such as
  # the host platform etc.
  #
  # Get the information returned from ws_job_exec_nnn which is
  # the job and task keys
  #
  echo "  echo \"Script Called\"">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \$RES | cut -d \"~\" -f2\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  MASTER_JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \$RES | cut -d \"~\" -f4 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \$RES | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \$RES | cut -d \"~\" -f8\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \$RES | cut -d \"~\" -f9\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  # Break out the returned variables">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  # Get the information from the script header file">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  #
  # Execute a sqlplus command to get information from the header
  # table about the script we are to run
  #
  echo "  RES=\`sqlplus -s <<WSL010EOF2 | grep -v \"rows selected.$\" | grep -v \"^$\" | tr -d \"\\015\" | tr -s \"\\012\" \",\" ">>$THREAD_CMD
  echo "  \$DSS_USER/\$DSS_PWD">>$THREAD_CMD
  echo "  set sqlprompt \"\";">>$THREAD_CMD
  echo "  set heading off;">>$THREAD_CMD
  echo "  set pagesize 0;">>$THREAD_CMD
  echo "  set linesize 256;">>$THREAD_CMD
  echo "  set trimspool on;">>$THREAD_CMD
  echo "  set echo off;">>$THREAD_CMD
  echo "  Select nvl(wtsh_host_type,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_work_dir,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_script_type,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_load_type,' ')||','||">>$THREAD_CMD
  echo "         nvl(wtsh_script_key,0)||','||">>$THREAD_CMD
  echo "         nvl(wtsh_load_key,0)||','||">>$THREAD_CMD
  echo "         nvl(wtsh_connect_key,0)||','||">>$THREAD_CMD
  echo "         nvl(wjr_restart,0)||','||">>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "                 THEN SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~=')," >>$THREAD_CMD
  echo "                                                                                                                                          LENGTH(src.dc_authentication)),';')," >>$THREAD_CMD
  echo "                                                         CASE WHEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') > 0" >>$THREAD_CMD
  echo "                                                              THEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletUser~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletUser~='), " >>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') - 1" >>$THREAD_CMD
  echo "                                                              ELSE LENGTH(src.dc_authentication)" >>$THREAD_CMD
  echo "                                                         END)" >>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END||' ,'||" >>$THREAD_CMD
  echo "                      nvl(src.dc_extract_userid,' ')||','||" >>$THREAD_CMD
  echo "         CASE WHEN src.dc_authentication like '%TDWalletUser~=%' AND src.dc_authentication like '%TDWalletStr~=%'" >>$THREAD_CMD
  echo "               THEN SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~='),">>$THREAD_CMD
  echo "                                                                                                                                          LENGTH(src.dc_authentication)),';'),">>$THREAD_CMD
  echo "                                                         CASE WHEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') > 0">>$THREAD_CMD
  echo "                                                              THEN INSTR( SUBSTR(src.dc_authentication,  INSTR(src.dc_authentication, 'TDWalletStr~=') + INSTR(SUBSTR(src.dc_authentication, INSTR(src.dc_authentication, 'TDWalletStr~='), ">>$THREAD_CMD
  echo "                                                                                                                                                               LENGTH(src.dc_authentication)),';'), 100),';') - 1">>$THREAD_CMD
  echo "                                                              ELSE LENGTH(src.dc_authentication)">>$THREAD_CMD
  echo "                                                         END)">>$THREAD_CMD
  echo "                      ELSE '' " >>$THREAD_CMD
  echo "                      END||' ,'||" >>$THREAD_CMD
  echo "                      nvl(src.dc_extract_pwd,' ')||',' DATA_STREAM " >>$THREAD_CMD
  echo "  From ws_wrk_task_scr_hdr">>$THREAD_CMD
  echo "  Left Outer Join ws_wrk_job_run On wtsh_job_key = wjr_job_key">>$THREAD_CMD
  echo "  Left Outer Join (Select ec_obj_key obj_key, Max(ec_src_table) src_table From ws_export_col Group By ec_obj_key) export_tab On wtsh_load_key = export_tab.obj_key ">>$THREAD_CMD
  echo "  Left Outer Join ws_obj_object On export_tab.src_table = oo_name ">>$THREAD_CMD
  echo "  Left Outer Join ws_dbc_target On oo_target_key = dt_target_key ">>$THREAD_CMD
  echo "  Left Outer Join ws_dbc_connect src On (oo_target_key <> 0 And dt_connect_key = src.dc_obj_key) Or (oo_target_key = 0 And src.dc_attributes Like '%DataWarehouse;%') ">>$THREAD_CMD
  echo "  Where wtsh_job_key = \$JOB_KEY">>$THREAD_CMD
  echo "  And wtsh_task_key = \$TASK_KEY">>$THREAD_CMD
  echo "  And wtsh_sequence = \$SEQ;">>$THREAD_CMD
  echo "  exit;">>$THREAD_CMD
  echo "WSL010EOF2\`">>$THREAD_CMD
  #
  # Get all the information stored in the header table
  # Check that this is a Unix script.
  # If not Unix then unsupported.
  #
  echo "  #">>$THREAD_CMD
  echo "  # See what type of script we have">>$THREAD_CMD
  echo "  # If not a Unix script then not supported">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  echo \"\$RES\"">>$THREAD_CMD
  echo "  HOST_TYPE=\`echo \$RES | cut -d \",\" -f1\`">>$THREAD_CMD
  echo "  WORK_DIR=\`echo \$RES | cut -d \",\" -f2\`">>$THREAD_CMD
  echo "  SCRIPT_TYPE=\`echo \$RES | cut -d \",\" -f3\`">>$THREAD_CMD
  echo "  LOAD_TYPE=\`echo \$RES | cut -d \",\" -f4\`">>$THREAD_CMD
  echo "  SCRIPT_KEY=\`echo \$RES | cut -d \",\" -f5 | tr -d \" \"\`">>$THREAD_CMD
  echo "  LOAD_KEY=\`echo \$RES | cut -d \",\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  CONNECT_KEY=\`echo \$RES | cut -d \",\" -f7 | tr -d \" \"\`">>$THREAD_CMD
  echo "  RESTART_COUNT=\`echo \$RES | cut -d \",\" -f8 | tr -d \" \"\`; export RESTART_COUNT">>$THREAD_CMD

  echo "    SRC_USER=\`echo \$RES | cut -d \",\" -f9 | tr -d \" \"\`; export SRC_USER">>$THREAD_CMD
  # If Wallet user is set then use it, else revert to use the std extract user
  echo "    if [ \"\$SRC_USER\" \!\= \"\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      SRC_PWD=\`echo \$RES | cut -d \",\" -f11 | tr -d \" \"\`">>$THREAD_CMD
  echo "      SRC_PWD=\\\$tdwallet\(\$SRC_PWD\); export SRC_PWD">>$THREAD_CMD
  echo "    else">>$THREAD_CMD
  echo "      SRC_USER=\`echo \$RES | cut -d \",\" -f10 | tr -d \" \"\`; export SRC_USER">>$THREAD_CMD
  echo "      SRC_PWD=\`echo \$RES | cut -d \",\" -f12 | tr -d \" \"\`; export SRC_PWD">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD

  echo "    META_USER=\${META_USER-\${DSS_USER}}; export META_USER">>$THREAD_CMD
  echo "    META_PWD=\${META_PWD-\${DSS_PWD}}; export META_PWD">>$THREAD_CMD

  echo "  #">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  #
  # Not Unix so not supported. We will process through the loop
  # again to pass the unsupported message back to the scheduler.
  #
  echo "  if [ \"\$HOST_TYPE\" != "U" ] && [ \"\$HOST_TYPE\" != "H" ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    echo \"Unix scheduler does not support Non Unix loads and scripts\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Unix scheduler does not support Non Unix loads and scripts \$HOST_TYPE \"">>$THREAD_CMD
  echo "    TASK_STATUS=-2">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  echo "  else">>$THREAD_CMD
  #
  # Unix script so create a unique script, audit file and error file name
  # which will be located in the work directory as defined in the connection
  # for the load table or script that generated this script.
  #
  echo "    #">>$THREAD_CMD
  echo "    # create a unique name for our script, audit and error trail">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    THREAD_BASE=\"\${WORK_DIR}wsl\${SEQ}j\${JOB_KEY}t\${TASK_KEY}\"">>$THREAD_CMD
  echo "    THREAD_SH=\"\$THREAD_BASE.sh\"">>$THREAD_CMD
  echo "    THREAD_SCRIPT=\"\$THREAD_BASE.script\"">>$THREAD_CMD
  echo "    THREAD_AUD=\"\$THREAD_BASE.aud\"">>$THREAD_CMD
  echo "    THREAD_ERR=\"\$THREAD_BASE.err\"">>$THREAD_CMD
  echo "    echo \"Script \$THREAD_SH\"">>$THREAD_CMD
  echo "    echo \"Audit \$THREAD_AUD\"">>$THREAD_CMD
  echo "    echo \"Error \$THREAD_ERR\"">>$THREAD_CMD
  echo "    # Get the actual script">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # Get the script itself into the unique script file
  # from the ws_wrk_task_scr_line table
  #
  echo "    sqlplus -s <<WSL010EOF3 | grep -v \"rows selected.$\" | grep -v \"^$\" | tr -d \"\\015\" >\$THREAD_SH">>$THREAD_CMD
  echo "    \$DSS_USER/\$DSS_PWD">>$THREAD_CMD
  echo "    set sqlprompt \"\";">>$THREAD_CMD
  echo "    set heading off;">>$THREAD_CMD
  echo "    set pagesize 0;">>$THREAD_CMD
  echo "    set linesize 256;">>$THREAD_CMD
  echo "    set trimspool on;">>$THREAD_CMD
  echo "    set echo off;">>$THREAD_CMD
  echo "    Select wtsl_line from ws_wrk_task_scr_line">>$THREAD_CMD
  echo "    Where wtsl_job_key = \$JOB_KEY">>$THREAD_CMD
  echo "    And wtsl_task_key = \$TASK_KEY">>$THREAD_CMD
  echo "    And wtsl_sequence = \$SEQ">>$THREAD_CMD
  echo "    Order by wtsl_line_no;">>$THREAD_CMD
  echo "    exit;">>$THREAD_CMD
  echo "WSL010EOF3">>$THREAD_CMD
  #
  # Remove the body of the script from the script file and put it in a
  # separate file that is invoked from the script file. The special token
  # ~~WSL_CUT_HERE~~ tells us where to break the script.
  #
  echo "    CUT_LINE_NO=\`grep -n \"~~WSL_CUT_HERE~~\" \"\$THREAD_SH\" | cut -d: -f1\`">>$THREAD_CMD
  echo "    if [ \"\$CUT_LINE_NO\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      sed \"\$CUT_LINE_NO,\\\$d\" \"\$THREAD_SH\" >\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "      echo \\\"\$THREAD_SCRIPT\\\" >>\"\$THREAD_SH\".tmp">>$THREAD_CMD
  echo "      sed \"1,\${CUT_LINE_NO}d\" \"\$THREAD_SH\" >\"\$THREAD_SCRIPT\"">>$THREAD_CMD
  echo "      mv \"\$THREAD_SH\".tmp \"\$THREAD_SH\"">>$THREAD_CMD
  echo "      chmod 750 \$THREAD_SCRIPT">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  #
  # Execute the script
  # The standard is that the first row on standard output is the result code
  # being either 1=success, -1=warning, -2=error, -3=fatal error
  # The second row on standard out will be the returned message
  #
  echo "    chmod 750 \$THREAD_SH">>$THREAD_CMD
  echo "    \$THREAD_SH \"\$JOB_NAME\" \"\$TASK_NAME\" \$JOB_KEY \$TASK_KEY \$SEQ >\$THREAD_AUD 2>\$THREAD_ERR">>$THREAD_CMD
  echo "    TASK_STATUS=\`awk 'NF>0' \$THREAD_AUD | head -1 | tr -d \" \"\`">>$THREAD_CMD
  echo "    TASK_MSG=\`awk 'NF>0' \$THREAD_AUD | head -2 | tail -1\`">>$THREAD_CMD
  echo "    if [ \"\$TASK_STATUS\" != \"1\" -a \"\$TASK_STATUS\" != \"-1\" -a \"\$TASK_STATUS\" != \"-2\"  -a \"\$TASK_STATUS\" != \"-3\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      TASK_MSG_TMP=\"Invalid return code: \$TASK_STATUS. return_msg: \$TASK_MSG\"">>$THREAD_CMD
  echo "      TASK_MSG=\`echo \$TASK_MSG_TMP | cut -c1-255\`">>$THREAD_CMD
  echo "      TASK_STATUS=-3">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "    bMORE=\"Y\"">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "    # Put out any additional rows to the workflow audit trail">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  #
  # If there are any additional rows in standard out then write then to
  # the audit trail
  #
  echo "    LIN=\`cat \$THREAD_AUD | wc -l | tr -d \" \"\`">>$THREAD_CMD
  echo "    echo \"\$LIN audit lines\"">>$THREAD_CMD
  echo "    if [ \"\$LIN\" != \"2\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      ROWNUM=0">>$THREAD_CMD
  echo "      while [ \"\$ROWNUM\" -lt \"\$LIN\" ]">>$THREAD_CMD
  echo "      do">>$THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM+1\"">>$THREAD_CMD
  echo "        if [ \"\$ROWNUM\" -gt \"2\" ] ">>$THREAD_CMD
  echo "        then">>$THREAD_CMD
  echo "          AUD_TRAIL=\`cat \$THREAD_AUD |head -\$ROWNUM | tail -1| sed \"s/'/''/g\"\`">>$THREAD_CMD
  echo "          sqlplus -s <<WSL010EOF4">>$THREAD_CMD
  echo "          $DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "          variable x number;">>$THREAD_CMD
  echo "          exec :x := wswrkaudit('I','\$JOB_NAME','\$TASK_NAME',\$SEQ,'\$AUD_TRAIL','','',\$TASK_KEY,\$JOB_KEY);">>$THREAD_CMD
  echo "          exit;">>$THREAD_CMD
  echo "WSL010EOF4">>$THREAD_CMD
  echo "        fi">>$THREAD_CMD
  echo "      done">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  #
  # If any rows in standard error then write them to the error/detail trail
  #
  echo "    LIN=\`cat \$THREAD_ERR | wc -l | tr -d \" \"\`">>$THREAD_CMD
  echo "    echo \"\$LIN error trail lines\"">>$THREAD_CMD
  echo "    if [ \"\$LIN\" != \"0\" ] ">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      ROWNUM=0">>$THREAD_CMD
  echo "      while [ \"\$ROWNUM\" -lt \"\$LIN\" ]">>$THREAD_CMD
  echo "      do">>$THREAD_CMD
  echo "        let ROWNUM=\"\$ROWNUM+1\"">>$THREAD_CMD
  echo "        ERR_TRAIL=\`cat \$THREAD_ERR | head -\$ROWNUM | tail -1 | sed \"s/'/''/g\"\`">>$THREAD_CMD
  echo "        sqlplus -s <<WSL010EOF5">>$THREAD_CMD
  echo "        $DSS_USER/$DSS_PWD">>$THREAD_CMD
  echo "        variable x number;">>$THREAD_CMD
  echo "        exec :x := wswrkerror('I','\$JOB_NAME','\$TASK_NAME',\$SEQ,'\$ERR_TRAIL','','',\$TASK_KEY,\$JOB_KEY,'');">>$THREAD_CMD
  echo "        exit;">>$THREAD_CMD
  echo "WSL010EOF5">>$THREAD_CMD
  echo "      done">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    #">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD
  #
  # Here if we returned a 90 or 91 from ws_job_exec_nnn which indicates a BDA Server task
  # 90 indicates BDA Server tasks to run completely in the BDA Server in Scheduler mode;
  #    a rejoin which does not attempt post actions is to be used.
  # 91 indicates BDA Server tasks to run partially in the BDA Server in Scheduler mode;
  #    pre and post actions cannot be performed in the BDA Server for non-Hive targets;
  #    these need to be done in the Scheduler, not the BDA Server;
  #    a rejoin which does attempt post actions is to be used.
  #
  echo "elif [ \"\$RET_CODE\" -eq 90 -o \"\$RET_CODE\" -eq 91 ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \"\$RES\" | cut -d \"~\" -f2\`">>$THREAD_CMD
  echo "  MASTER_JOB_KEY=\`echo \"\$RES\" | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \"\$RES\" | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \"\$RES\" | cut -d \"~\" -f4 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \"\$RES\" | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \"\$RES\" | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \"\$RES\" | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \"\$RES\" | cut -d \"~\" -f8\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \"\$RES\" | cut -d \"~\" -f9\`">>$THREAD_CMD
  echo "  TASK_DATA=\`echo \"\$RES\" | cut -d \"~\" -f10\`">>$THREAD_CMD
  echo "  BDA_SRVR_HOST=\`echo \"\$TASK_DATA\" | sed -e\"s@\\\\[WSH]@~@g\" -e\"s@.*CP_BDA_Host~\\\\([^~]*\\\\)~.*@\\\\1@\"\`">>$THREAD_CMD
  echo "  BDA_SRVR_PORT=\`echo \"\$TASK_DATA\" | sed -e\"s@\\\\[WSH]@~@g\" -e\"s@.*CP_BDA_Port~\\\\([^~]*\\\\)~.*@\\\\1@\"\`">>$THREAD_CMD
  echo "  BDA_SRVR_APP=\`echo \"\$TASK_DATA\" | sed -e\"s@\\\\[WSH]@~@g\" -e\"s@.*CP_BDA_Context~\\\\([^~]*\\\\)~.*@\\\\1@\"\`">>$THREAD_CMD
  echo "  BDA_TASK_OBJ_KEY=\`echo \"\$TASK_DATA\" | sed -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_ObjKey~\\\\([^~]*\\\\)~.*@\\\\1@\"\`">>$THREAD_CMD
  echo "  BDA_TASK_ACTION=\`echo \"\$TASK_DATA\" | sed -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_Action~\\\\([^~]*\\\\)~.*@\\\\1@\"\`">>$THREAD_CMD
  echo "  BDA_SECRET_ID=\`echo \"\$TASK_DATA\" | sed -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_SecretId~\\\\([^~]*\\\\)~.*@\\\\1@\"\`">>$THREAD_CMD
  echo "  BDA_SECRET=\`echo \"\$TASK_DATA\" | sed -e\"s@\\\\[WSH]@~@g\" -e\"s@.*SCH_BDA_Secret~\\\\([^~]*\\\\)~.*@\\\\1@\"\`">>$THREAD_CMD
  echo "  BDA_TASK_SEQ=\"\$SEQ\"">>$THREAD_CMD
  echo "  BDA_TASK_KEY=\"\$TASK_KEY\"">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  JSON_PATN_WHITESPACE=\"[ \\\\t\\\\n\\\\r]*\"">>$THREAD_CMD
  echo "  JSON_PATN_NUMBER=\"\\\\([-]\\\\{0,1\\\\}[1-9][0-9]*\\\\)\"">>$THREAD_CMD
  echo "  JSON_PATN_STRING=\"\\\"\\\\(\\\\([^\\\"\\\\\\\\]\\\\|\\\\\\\\[\\\"\\\\\\\\/bfnrt]\\\\)*\\\\)\\\"\"">>$THREAD_CMD
  echo "  JSON_PATN_NVP_PREFIX=\"[{,]\"">>$THREAD_CMD
  echo "  JSON_PATN_NVP_SUFFIX=\"[,}]\"">>$THREAD_CMD
  echo "  BDA_TASK_RESPONSE_PATN_RUN_KEY=\"\$JSON_PATN_NVP_PREFIX\$JSON_PATN_WHITESPACE\\\"runId\\\"\$JSON_PATN_WHITESPACE:\$JSON_PATN_WHITESPACE\$JSON_PATN_NUMBER\$JSON_PATN_WHITESPACE\$JSON_PATN_NVP_SUFFIX\"">>$THREAD_CMD
  echo "  BDA_TASK_RESPONSE_PATN_TASK_STATUS=\"\$JSON_PATN_NVP_PREFIX\$JSON_PATN_WHITESPACE\\\"taskStatus\\\"\$JSON_PATN_WHITESPACE:\$JSON_PATN_WHITESPACE\$JSON_PATN_STRING\$JSON_PATN_WHITESPACE\$JSON_PATN_NVP_SUFFIX\"">>$THREAD_CMD
  echo "  BDA_TASK_RESPONSE_PATN_ERROR_MSG=\"\$JSON_PATN_NVP_PREFIX\$JSON_PATN_WHITESPACE\\\"message\\\"\$JSON_PATN_WHITESPACE:\$JSON_PATN_WHITESPACE\$JSON_PATN_STRING\$JSON_PATN_WHITESPACE\$JSON_PATN_NVP_SUFFIX\"">>$THREAD_CMD
  echo "  BDA_TASK_DATA=\"{\\\"objectId\\\":\$BDA_TASK_OBJ_KEY, \\\"actionType\\\":\$BDA_TASK_ACTION, \\\"sequenceId\\\":\$BDA_TASK_SEQ, \\\"taskId\\\":\$BDA_TASK_KEY}\"">>$THREAD_CMD
  echo "  BDA_TASK_URL=\"http://\$BDA_SRVR_HOST:\$BDA_SRVR_PORT/\$BDA_SRVR_APP/rest/v1/task\"">>$THREAD_CMD
  echo "  BDA_AUTH_HMAC=\`printf '%s\\000%s' \"\$BDA_TASK_URL\" \"\$BDA_TASK_DATA\" | openssl dgst -sha256 -hmac \"\$BDA_SECRET\" -binary | openssl enc -base64\`">>$THREAD_CMD
  echo "  BDA_AUTH_HEADER=\"Authorization: WSL-SharedSecret-v1 SecretType=Metadata, SecretId=\$BDA_SECRET_ID, HMAC=\\\"\$BDA_AUTH_HMAC\\\"\"">>$THREAD_CMD
  echo "  BDA_TASK_RESPONSE=\`curl -s -S -i -H\"Accept: application/json\" -H\"Content-Type: application/json\" -H\"\$BDA_AUTH_HEADER\" -d\"\$BDA_TASK_DATA\" \"\$BDA_TASK_URL\" 2>&1\`">>$THREAD_CMD
  echo "  BDA_TASK_CURL_STATUS_CODE=\"\$?\"">>$THREAD_CMD
  echo "  echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | grep -e\"\$BDA_TASK_RESPONSE_PATN_RUN_KEY\" >/dev/null">>$THREAD_CMD
  echo "  if [ \"\$?\" -eq 0 ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    BDA_TASK_RUN_KEY=\`echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | sed -e\"s@.*\$BDA_TASK_RESPONSE_PATN_RUN_KEY.*@\\1@\"\`">>$THREAD_CMD
  echo "  else">>$THREAD_CMD
  echo "    BDA_TASK_RUN_KEY=\"\"">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD
  echo "  while [ true ]">>$THREAD_CMD
  echo "  do">>$THREAD_CMD
  echo "    if [ \"\$BDA_TASK_CURL_STATUS_CODE\" -ne 0 ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      BDA_TASK_CURL_STATUS_MSG=\"\$BDA_TASK_RESPONSE\"">>$THREAD_CMD
  echo "      TASK_MSG=\"BDA connection failure: \$BDA_TASK_CURL_STATUS_MSG\"">>$THREAD_CMD
  echo "      TASK_STATUS=-3">>$THREAD_CMD
  echo "      break">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    BDA_TASK_HTTP_STATUS_CODE=\`echo \"\$BDA_TASK_RESPONSE\" | head -1 | cut -d\" \" -f2\`">>$THREAD_CMD
  echo "    if [ \"\$BDA_TASK_HTTP_STATUS_CODE\" -ge 400 ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | grep -e\"\$BDA_TASK_RESPONSE_PATN_ERROR_MSG\" >/dev/null">>$THREAD_CMD
  echo "      if [ \"\$?\" -eq 0 ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        BDA_TASK_ERROR_MSG=\`echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | sed -e\"s@.*\$BDA_TASK_RESPONSE_PATN_ERROR_MSG.*@\\1@\"\`">>$THREAD_CMD
  echo "        TASK_MSG=\"BDA operation failed: \$BDA_TASK_ERROR_MSG\"">>$THREAD_CMD
  echo "      else">>$THREAD_CMD
  echo "        BDA_TASK_HTTP_STATUS_MSG=\`echo \"\$BDA_TASK_RESPONSE\" | head -1 | cut -d\" \" -f3-\`">>$THREAD_CMD
  echo "        TASK_MSG=\"BDA connection failure: \$BDA_TASK_HTTP_STATUS_CODE \$BDA_TASK_HTTP_STATUS_MSG\"">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      TASK_STATUS=-3">>$THREAD_CMD
  echo "      break">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | grep -e\"\$BDA_TASK_RESPONSE_PATN_TASK_STATUS\" >/dev/null">>$THREAD_CMD
  echo "    if [ \"\$?\" -ne 0 ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      TASK_MSG=\"BDA operation failed: Invalid response message.\"">>$THREAD_CMD
  echo "      TASK_STATUS=-3">>$THREAD_CMD
  echo "      break">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    BDA_TASK_STATUS=\`echo \"\$BDA_TASK_RESPONSE\" | tr \"\\n\" \" \" | sed -e\"s@.*\$BDA_TASK_RESPONSE_PATN_TASK_STATUS.*@\\1@\"\`">>$THREAD_CMD
  echo "    if [ \"\$BDA_TASK_STATUS\" != \"P\" -a \"\$BDA_TASK_STATUS\" != \"R\" ]">>$THREAD_CMD
  echo "    then">>$THREAD_CMD
  echo "      if [ \"\$BDA_TASK_STATUS\" = \"C\" ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        TASK_MSG=\"BDA operation completed successfully.\"">>$THREAD_CMD
  echo "        TASK_STATUS=1">>$THREAD_CMD
  echo "      elif [ \"\$BDA_TASK_STATUS\" = \"W\" ]">>$THREAD_CMD
  echo "      then">>$THREAD_CMD
  echo "        TASK_MSG=\"BDA operation completed with warnings.\"">>$THREAD_CMD
  echo "        TASK_STATUS=-1">>$THREAD_CMD
  echo "      else">>$THREAD_CMD
  echo "        TASK_MSG=\"BDA operation failed.\"">>$THREAD_CMD
  echo "        TASK_STATUS=-2">>$THREAD_CMD
  echo "      fi">>$THREAD_CMD
  echo "      break">>$THREAD_CMD
  echo "    fi">>$THREAD_CMD
  echo "    sleep 1s">>$THREAD_CMD
  echo "    BDA_AUTH_HMAC=\`printf '%s\\000%s' \"\$BDA_TASK_URL/\$BDA_TASK_RUN_KEY\" \"\" | openssl dgst -sha256 -hmac \"\$BDA_SECRET\" -binary | openssl enc -base64\`">>$THREAD_CMD
  echo "    BDA_AUTH_HEADER=\"Authorization: WSL-SharedSecret-v1 SecretType=Metadata, SecretId=\$BDA_SECRET_ID, HMAC=\\\"\$BDA_AUTH_HMAC\\\"\"">>$THREAD_CMD
  echo "    BDA_TASK_RESPONSE=\`curl -s -S -i -H\"Accept: application/json\" -H\"\$BDA_AUTH_HEADER\" \"\$BDA_TASK_URL/\$BDA_TASK_RUN_KEY\" 2>&1\`">>$THREAD_CMD
  echo "    BDA_TASK_CURL_STATUS_CODE=\"\$?\"">>$THREAD_CMD
  echo "  done">>$THREAD_CMD
  echo "  ACTION=\"REJOIN\$RET_CODE\"">>$THREAD_CMD
  echo "  bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned an 18 (remote object) or 22 (on-the-fly template Create DDL) report an error
  # as remote object are not implemented for Unix/Linux schedulers
  #
  echo "elif [ \"\$RET_CODE\" -eq 18 -o \"\$RET_CODE\" -eq 22 ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  RESULT_MSG=\`echo \$RES | cut -d \"~\" -f2\`">>$THREAD_CMD
  echo "  JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  MASTER_JOB_KEY=\`echo \$RES | cut -d \"~\" -f3 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_KEY=\`echo \$RES | cut -d \"~\" -f4 | tr -d \" \"\`">>$THREAD_CMD
  echo "  TASK_NAME=\`echo \$RES | cut -d \"~\" -f5\`">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "  REJOIN_JOB_LIST=\`echo \$RES | cut -d \"~\" -f8\`">>$THREAD_CMD
  echo "  REJOIN_TASK_LIST=\`echo \$RES | cut -d \"~\" -f9\`">>$THREAD_CMD
  echo "  #">>$THREAD_CMD
  echo "  if [ \"\$RET_CODE\" -eq 18 ]">>$THREAD_CMD
  echo "  then">>$THREAD_CMD
  echo "    echo \"Loads for remote objects can't be executed in the Unix/Linux scheduler.\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Loads for remote objects can't be executed in the Unix/Linux scheduler.\"">>$THREAD_CMD
  echo "  else">>$THREAD_CMD
  echo "    echo \"Template based Create DDL Override is not supported by the Unix/Linux scheduler.\"">>$THREAD_CMD
  echo "    TASK_MSG=\"Template based Create DDL Override is not supported by the Unix/Linux scheduler.\"">>$THREAD_CMD
  echo "  fi">>$THREAD_CMD
  echo "  TASK_STATUS=-2">>$THREAD_CMD
  echo "  ACTION=\"REJOIN\"">>$THREAD_CMD
  echo "  bMORE=\"Y\"">>$THREAD_CMD
  #
  # Here if we returned a -1 from ws_job_exec_nnn which indicates a warning completion
  # May need to PAGE or MAIL if the action is set.
  #
  echo "elif [ \"\$RET_CODE\" = \"-1\" ]">>$THREAD_CMD
  echo "then">>$THREAD_CMD
  echo "  echo \"Warning completion\"">>$THREAD_CMD
  echo "  bMORE=\"N\"">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  #
  # Here if we returned a an error from ws_job_exec_nnn which indicates a failure
  # May need to PAGE or MAIL if the action is set.
  #
  echo "else">>$THREAD_CMD
  echo "  echo \"\$RES\"">>$THREAD_CMD
  echo "  echo \"Error completion\"">>$THREAD_CMD
  echo "  bMORE=\"N\"">>$THREAD_CMD
  echo "  ACTION_KEY=\`echo \$RES | cut -d \"~\" -f6 | tr -d \" \"\`">>$THREAD_CMD
  echo "  ACTION_MSG=\`echo \$RES | cut -d \"~\" -f7\`">>$THREAD_CMD
  echo "fi">>$THREAD_CMD
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
