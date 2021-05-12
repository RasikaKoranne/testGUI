-- =============================================================================
-- DBMS Name               :	Oracle
-- Script Name             :	ws_sep_meta_data_add_grants
-- Description             :	Add grants to allow for the data warehouse to 
--                              exist in a different schema from the RED meta data.
-- Usage                   :    Compile this procedure in the RED meta data schema.
--                              Run this procedure as the RED meta data schema owner.
-- WhereScape Limited, inc. All rights reserved. (C) Copyright 1996-2003
-- =============================================================================
-- Notes / History
--
-- JML  09/07/2003     Version 1.0.0

CREATE OR REPLACE PROCEDURE ws_sep_meta_data_add_grants
( p_warehouse_schema        IN  VARCHAR2)
AS

  v_ret_msg                 VARCHAR2(255);
  v_sql                     VARCHAR2(4000);
  v_step                    NUMBER;

  -- Cursor to get all objects in the red schema to be granted with
  -- derived privilages field.
  CURSOR c_red_objects IS
  SELECT object_name
       , CASE WHEN object_type IN ('TABLE','VIEW') THEN 'SELECT,INSERT,UPDATE,DELETE'
              WHEN object_type = 'SEQUENCE' THEN 'SELECT'
              ELSE 'EXECUTE'
         END privilages
  FROM   user_objects
  WHERE  object_type IN ('TABLE','VIEW','FUNCTION','PROCEDURE','PACKAGE','SEQUENCE')
  AND    object_name <> 'WS_SEP_META_DATA_ADD_GRANTS';

BEGIN

  v_step := 10;

  -- Loop on objects and add grants.
  FOR r_red_objects IN c_red_objects LOOP

    v_step := 20;

    v_sql := 'GRANT '||r_red_objects.privilages||' ON '||
             r_red_objects.object_name||' TO '||p_warehouse_schema;

    EXECUTE IMMEDIATE v_sql;
    --DBMS_OUTPUT.put_line(v_sql);

  END LOOP;

  v_step := 30;

  v_ret_msg := 'Grants Added Sucessfully';
  DBMS_OUTPUT.put_line(v_ret_msg);

  RETURN;

EXCEPTION

  WHEN OTHERS THEN

     v_ret_msg := 'Unexpected Error in ws_seperate_meta_data.add_grants, step '||
                  v_step||' '||SQLERRM;

     DBMS_OUTPUT.put_line(v_ret_msg);

     ROLLBACK;

     RETURN;

END ws_sep_meta_data_add_grants;
/


