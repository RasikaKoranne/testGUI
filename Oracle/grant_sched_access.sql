grant select                      on ws_meta to dsssched;
grant select                      on ws_meta_names to dsssched;
grant select                      on ws_meta_tables to dsssched;
grant select                      on ws_table_attributes to dsssched;
grant select                      on ws_obj_group to dsssched;
grant select                      on ws_obj_object to dsssched;
grant select                      on ws_obj_pro_map to dsssched;
grant select                      on ws_obj_project to dsssched;
grant select                      on ws_obj_type to dsssched;
grant select                      on ws_pro_gro_map to dsssched;

grant select,insert,update        on ws_user_adm to dsssched;

grant select,update               on ws_wrk_scheduler to dsssched;

grant select,insert,update,delete on ws_wrk_dependency to dsssched;
grant select,insert,update,delete on ws_wrk_job_dependency to dsssched;

grant select,insert,update,delete on ws_wrk_job_ctrl to dsssched;
grant select,insert,delete        on ws_wrk_job_log to dsssched;
grant select,update,delete        on ws_wrk_job_run to dsssched;
grant select,delete               on ws_wrk_job_thread to dsssched;
grant select,insert,update,delete on ws_wrk_task_ctrl to dsssched;
grant select,update,delete        on ws_wrk_task_run to dsssched;
grant select,insert,delete        on ws_wrk_task_log to dsssched;

grant select,insert,update,delete on ws_wrk_audit_log to dsssched;
grant select,insert,update,delete on ws_wrk_error_log to dsssched;
grant execute                     on wswrkaudit to dsssched;

grant select,insert,update        on dss_parameter to dsssched;

grant select,alter                on ws_job_seq to dsssched;
grant select,alter                on ws_task_seq to dsssched;
grant select,alter                on ws_user_adm_seq to dsssched;
grant select,alter                on ws_wrk_job_dependency_seq to dsssched;

-- The following is required to include calls to check job status
grant execute                     on ws_sched_status to dsssched;

-- The following are required to use the right mouse 'used by' option in the parameters listing.
grant select                      on ws_pro_header to dsssched;
grant select                      on ws_pro_line to dsssched;
grant select                      on ws_scr_header to dsssched;
grant select                      on ws_scr_line to dsssched;
grant select                      on ws_load_tab to dsssched;
grant select                      on ws_load_col to dsssched;
grant select                      on ws_stage_tab to dsssched;
grant select                      on ws_stage_col to dsssched;
grant select                      on ws_dim_tab to dsssched;
grant select                      on ws_dim_col to dsssched;
grant select                      on ws_fact_tab to dsssched;
grant select                      on ws_fact_col to dsssched;
grant select                      on ws_agg_tab to dsssched;
grant select                      on ws_agg_col to dsssched;

-- The following required for monitoring of job and database monitoring
-- NOTE: add insert, update and delete if full control fo job monitoring required.
grant select                      on ws_wrk_mon_status to dsssched;
grant select                      on ws_wrk_mon_db to dsssched;
grant select                      on ws_wrk_mon_job to dsssched;
grant select                      on ws_wrk_mon_log to dsssched;
grant select                      on ws_wrk_mon_notify to dsssched;
grant select                      on ws_wrk_mon_run to dsssched;
