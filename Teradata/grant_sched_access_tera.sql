-- =============================================================================
-- DBMS Name               :    Teradata
-- Script Name             :    grant_sched_access_tera.sql
-- Description             :    Grant permissions on the portions of the RED
--                              metadata required for an operator TO the 
--                              scheduler role.
-- Usage                   :    Run this procedure as a Teradata administrator user
--                              with sufficient authority grant RED metadata
--                              table permissions and with sufficient authority
--                              to grant roles and modify users.
--
-- WhereScape Limited, inc. All rights reserved. (C) Copyright 1996-2015
-- =============================================================================
--
-- Notes                   1) This is a sample script only.
--
--                         2) Before running, globally change red_repository 
--                            to the database containing the RED metadata.
--
--                         3) If desired, before running, globally change 
--                            red_sched_role to the required operator role name.
--
--                         4) Before running, globally change dsssched
--                            to the operator user.
--
--                         5) Run these two commands for additional users who
--                            need the operator role:
--
--                             GRANT red_sched_role TO AdditionalUser WITHADMIN OPTION; 
--                             MODIFY USER AdditionalUser AS ROLE=red_sched_role;
--
-- =============================================================================
-- Notes / History
--
-- JML  04-MAY-2015     Version 1.0
--
-- =============================================================================

CREATE ROLE red_sched_role;

GRANT SELECT ON red_repository.ws_dbc_connect TO red_sched_role;
GRANT SELECT ON red_repository.ws_meta TO red_sched_role;
GRANT SELECT ON red_repository.ws_meta_tables TO red_sched_role;
GRANT SELECT ON red_repository.ws_meta_names TO red_sched_role;
GRANT SELECT ON red_repository.ws_table_attributes TO red_sched_role;
GRANT SELECT ON red_repository.ws_obj_type TO red_sched_role;
GRANT SELECT ON red_repository.ws_obj_object TO red_sched_role;
GRANT SELECT ON red_repository.ws_obj_pro_map TO red_sched_role;
GRANT SELECT ON red_repository.ws_obj_project TO red_sched_role;
GRANT SELECT ON red_repository.ws_obj_group TO red_sched_role;
GRANT SELECT ON red_repository.ws_pro_gro_map TO red_sched_role;
GRANT SELECT ON red_repository.ws_wrk_audit_log TO red_sched_role;

GRANT SELECT,INSERT ON red_repository.ws_user_adm TO red_sched_role;
GRANT SELECT,DELETE ON red_repository.ws_wrk_error_log TO red_sched_role;
GRANT SELECT,UPDATE ON red_repository.ws_wrk_scheduler TO red_sched_role;

GRANT SELECT,INSERT,UPDATE,DELETE ON red_repository.ws_wrk_dependency TO red_sched_role;
GRANT SELECT,INSERT,UPDATE,DELETE ON red_repository.ws_wrk_job_ctrl TO red_sched_role;
GRANT SELECT,INSERT,DELETE ON red_repository.ws_wrk_job_log TO red_sched_role;
GRANT SELECT,UPDATE,DELETE ON red_repository.ws_wrk_job_run TO red_sched_role;
GRANT SELECT,INSERT,UPDATE,DELETE ON red_repository.ws_wrk_dependency TO red_sched_role;
GRANT SELECT,INSERT,UPDATE,DELETE ON red_repository.ws_wrk_job_dependency TO red_sched_role;
GRANT SELECT,DELETE ON red_repository.ws_wrk_job_thread TO red_sched_role;
GRANT SELECT,INSERT ON red_repository.ws_wrk_sequence TO red_sched_role;
GRANT SELECT,INSERT,UPDATE,DELETE ON red_repository.ws_wrk_task_ctrl TO red_sched_role;
GRANT SELECT,UPDATE,DELETE ON red_repository.ws_wrk_task_run TO red_sched_role;
GRANT SELECT,INSERT,DELETE ON red_repository.ws_wrk_task_log TO red_sched_role;
GRANT SELECT,INSERT,UPDATE ON red_repository.dss_parameter TO red_sched_role;

GRANT EXECUTE ON red_repository.wswrkaudit TO red_sched_role;
GRANT EXECUTE ON red_repository.ws_sched_status TO red_sched_role;

GRANT SELECT ON red_repository.ws_pro_header TO red_sched_role;
GRANT SELECT ON red_repository.ws_pro_line TO red_sched_role;
GRANT SELECT ON red_repository.ws_scr_header TO red_sched_role;
GRANT SELECT ON red_repository.ws_scr_line TO red_sched_role;
GRANT SELECT ON red_repository.ws_load_tab TO red_sched_role;
GRANT SELECT ON red_repository.ws_load_col TO red_sched_role;
GRANT SELECT ON red_repository.ws_stage_tab TO red_sched_role;
GRANT SELECT ON red_repository.ws_stage_col TO red_sched_role;
GRANT SELECT ON red_repository.ws_dim_tab TO red_sched_role;
GRANT SELECT ON red_repository.ws_dim_col TO red_sched_role;
GRANT SELECT ON red_repository.ws_agg_tab TO red_sched_role;
GRANT SELECT ON red_repository.ws_agg_col TO red_sched_role;

GRANT red_sched_role TO dsssched WITHADMIN OPTION; 
MODIFY USER dsssched AS ROLE=red_sched_role;
