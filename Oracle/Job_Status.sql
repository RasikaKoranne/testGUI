select  
	'Waiting' Type,
	wjc_name "Job Name",
	decode(wjc_status,'H','On Hold','R','Running','P','Pending','W','Waiting','C','Completed',
			'B','Blocked','F','Failed','G','Failed - Aborted','E','Error Completion','Unknown') "Status",
	wjc_sequence "Sequence", 
	wjc_start_after "Started/Scheduled",
	sysdate "Completed", 
	0 "hh" ,
	0 "mm", 
	0 "Okay",
	0 "Info",
	0 "Warn",
	0 "Detail",
	0 "Error"
	  from ws_wrk_job_ctrl
union  
	 select 'Running',wjr_name,
	decode(wjr_status,'H','On Hold','R','Running','P','Pending','W','Waiting','C','Completed',
			'B','Blocked','F','Failed','G','Failed - Aborted','E','Error Completion','Unknown') "Status",
	wjr_sequence, wjr_started, wjr_completed, 
	 trunc(to_number(sysdate-wjr_started)*24,0),  
	 round(to_number(sysdate-wjr_started)*24*60,0)  
	 - (trunc(to_number(sysdate-wjr_started)*24,0)*60),  
	 wjr_okay_count, 
	 wjr_info_count, wjr_warning_count, wjr_detail_count, 
	 wjr_error_count
	  from ws_wrk_job_run 
union  
	 select 'Finished',wjl_name,
	decode(wjl_status,'H','On Hold','R','Running','P','Pending','W','Waiting','C','Completed',
			'B','Blocked','F','Failed','G','Failed - Aborted','E','Error Completion','Unknown') "Status",
	 wjl_sequence, wjl_started, wjl_completed, 
	 wjl_elapsed_hh, wjl_elapsed_mi, wjl_okay_count, 
	 wjl_info_count, wjl_warning_count, wjl_detail_count, 
	 wjl_error_count
	 from ws_wrk_job_log  
order by 1 DESC,4 DESC  ;
