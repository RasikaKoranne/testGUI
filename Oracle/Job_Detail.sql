select  wa_time_stamp, wa_sequence,wa_job, wa_task, wa_status, wa_message,wa_db_msg_desc 
from ws_wrk_audit_log
where wa_job = 'Daily Run'
and wa_sequence = ( select max(wa_sequence) from
                                 ws_wrk_audit_log where wa_job = 'Daily Run')
order by wa_time_stamp, wa_job, wa_task;
