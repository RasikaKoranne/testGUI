-- =============================================================================
-- DBMS Name               :    Oracle
-- Script Name             :    recreate_dssdemo.sql
-- Description             :    Creates a sample Oracle environment for RED
-- Usage                   :    Ammend script for your environment and run from an Oracle administration account.
--
-- WhereScape Limited, inc. All rights reserved. (C) Copyright 1996-2016
-- =============================================================================

-- Modify and uncomment for a new RED repository database account:

-- drop user dssdemo cascade;
-- create user dssdemo identified by wsl;
-- alter user dssdemo default tablespace DATA;
-- alter user dssdemo temporary tablespace TEMP;

grant create session to dssdemo;
grant resource to dssdemo;
grant create table to dssdemo;
grant create view to dssdemo;
grant create sequence to dssdemo;
grant create procedure to dssdemo;
grant select any table to dssdemo;
grant create materialized view to dssdemo;
grant create database link to dssdemo;
grant query rewrite to dssdemo;
grant select on sys.v_$database to dssdemo;
grant alter session to dssdemo;
grant select on sys.v_$session to dssdemo;
grant execute on sys.dbms_lock to dssdemo;
grant execute on sys.dbms_sql to dssdemo;
grant create any view to dssdemo;
grant unlimited tablespace to dssdemo;
grant alter system to dssdemo;
grant select_catalog_role to dssdemo;



-- NOTES: 
-- 1) select any table - this is only required to gain access to tables in other schema. It is not required if specific grants have been provided to the tables that are required, such as with the tutorial.
-- 2) as an alternative the ALTER SYSTEM privilege you can compile Ws_User_Abort (contained in C:\Program Files\WhereScape\Oracle) under the SYS user, then grant execute on SYS.Ws_User_Abort to dssdemo.



-- If using object placement across multiple schemas in WhereScape RED, the RED user also needs to be granted the following privileges: 


-- grant select any table to dssdemo;
-- grant create any view to dssdemo;
-- grant drop any view to dssdemo;
-- grant create any table to dssdemo;
-- grant drop any table to dssdemo;
-- grant delete any table to dssdemo;
-- grant insert any table to dssdemo;
-- grant update any table to dssdemo;
-- grant alter any table to dssdemo;
-- grant global query rewrite to dssdemo;
-- grant create any materialized view to dssdemo;
-- grant drop any materialized view to dssdemo;
-- grant alter any materialized view to dssdemo;
-- grant create any index to dssdemo;
-- grant drop any index to dssdemo;
-- grant alter any index to dssdemo;
-- grant select any sequence to dssdemo;
-- grant create any sequence to dssdemo;
-- grant drop any sequence to dssdemo;
-- grant analyze any to dssdemo;
-- grant comment any table to dssdemo;
-- grant select_catalog_role to dssdemo;



-- If loading from Hadoop using multiple schemas, the RED user also needs to be granted the following privilege:

-- grant select_catalog_role to dssdemo;


-- To leverage WSL Datavault V2.0 templates, the RED user also needs to be granted the following privilege:

-- grant execute on dbms_crypto to dssdemo;
