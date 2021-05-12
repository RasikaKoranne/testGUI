--
-- Executes a WhereScape RED job
--

variable i_sJobName    varchar2(64);
variable i_sTaskName   varchar2(64);
variable i_sAction     varchar2(24);
variable i_nThreadNo   number;
variable i_nSequence   number;
variable i_nJob        number;
variable i_nTask       number;
variable i_nTaskStatus number;
variable i_sTaskMsg    varchar2(256);
variable o_nResultCOde number;
variable o_sResultMsg  varchar2(256);
variable o_nJobKey     number;
variable o_nTaskKey    number;
variable o_sTaskName   varchar2(64);
variable o_sActionKey  number;
variable o_sActionMsg  varchar2(256);

--
-- The Job name must match the name exactly
-- The Job number will show in the job description when the job is first created
--
-- The Sequence number should be unique for each new run. A good starting point is job_no + 1
-- A Unique sequence number can be acquired from the ws_job_seq sequence
-- 
-- The Thread number must be zero for the first run of this script. Multiple thread can be
-- executed simply by starting another script with a higher sequential thread number.
--
BEGIN
:i_sJobName    := 'Daily';
:i_sTaskName   := '';
:i_sAction     := 'NEW';
:i_nThreadNo   := 0;
:i_nSequence   := 78;
:i_nJob        := 61;
:i_nTask       := 0;
:i_nTaskStatus := 0;
:i_sTaskMsg    := '';
END;
/

-- 
-- To Restart a job uncomment the code below between the --***** lines
--
--********************************************************************
--BEGIN
--:i_sAction     := 'RESTART';
--END;
--/
--
--Update ws_wrk_job_run
--Set wjr_status    = 'P'
--Where wjr_job_key = :i_nJob
--And wjr_sequence  = :i_nSequence
--And wjr_status   in ('H','F');
--
--********************************************************************
--


exec ws_job_exec_010(:i_sJobName,:i_sTaskName,:i_sAction,:i_nThreadNo,:i_nSequence,:i_nJob,:i_nTask,:i_nTaskStatus,:i_sTaskMsg,:o_nResultCode,:o_sResultMsg,:o_nJobKey,:o_nTaskKey,:o_sTaskName,:o_sActionKey,:o_sActionMsg);

--
-- NOTE: The result codes reflect the success or otherwise of the ws_job_exec_010 procedure.
--       They do not reflect the actual job results.
--       If a job fails the result code will still be 1 provided the failure is handled okay
--       by the ws_job_exec_010 procedure.
--
-- Result codes are as follows:
--  2 external task to run (e.g. unix or windows script)
--  1 completed okay
-- -2 Failed with a handled error
-- -3 Failed with unhandled error
--
-- The result msg will normally be set when there is a failure
-- Examine recent messages in ws_wrk_audit_log for the definitive result
--

print :o_nResultCode;
print :o_sResultMsg;


--
-- Now look at the actual job tables to see if the job finished okay.
-- Note: The i_nSequence number must be unique with each run otherwise this result information
--       will reflect all the jobs that ran with the sequence number
--
Select decode(wjr_status,'C','Completed','F','Failed','W','Waiting','A','Aborted','Unknown') "job Status",
       to_char(wjr_started,'DD-MON-YYYY HH24:MI') "job Started", 
       to_char(wjr_completed,'DD-MON-YYYY HH24:MI') "job completed",
       wjr_okay_count "Task success", wjr_warning_count "Warnings", wjr_error_count "Task errors"
From   ws_wrk_job_run where wjr_job_key = :i_nJob and wjr_sequence = :i_nSequence
Union
Select decode(wjl_status,'C','Completed','F','Failed','W','Waiting','A','Aborted','Unknown') "job Status",
       to_char(wjl_started,'DD-MON-YYYY HH24:MI') "job Started", 
       to_char(wjl_completed,'DD-MON-YYYY HH24:MI') "job completed",
       wjl_okay_count "Task success", wjl_warning_count "Warnings", wjl_error_count "Task errors"
From   ws_wrk_job_log where wjl_job_key = :i_nJob and wjl_sequence = :i_nSequence;

--
-- Get a definitive result to be returned to the calling job
-- Depending on how the calling process determines success or otherwise
-- the messages displayed above may need to be commented out
--
Select decode(wjr_status,'C','1','F','-2','W','0','A','-2','-3') "result"
From   ws_wrk_job_run where wjr_job_key = :i_nJob and wjr_sequence = :i_nSequence
Union
Select decode(wjl_status,'C','1','F','-2','W','0','A','-2','-3') "result"
From   ws_wrk_job_log where wjl_job_key = :i_nJob and wjl_sequence = :i_nSequence;


exit;