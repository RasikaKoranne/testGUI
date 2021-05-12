
-- =============================================================================
-- DBMS Name               :	Oracle
-- Script Name             :	ws_sep_meta_data_create_syns
-- Description             :	Add synonyms to allow for the data warehouse to 
--                              exist in a different schema from the RED meta data.
-- Usage                   :    Compile this procedure in the RED meta data schema.
--                              Run this procedure as the data warehouse schema owner.
-- WhereScape Limited, inc. All rights reserved. (C) Copyright 1996-2003
-- =============================================================================
-- Notes / History
--
-- JML  09/07/2003     Version 1.0.0

CREATE OR REPLACE PROCEDURE ws_sep_meta_data_create_syns
( p_red_schema              IN  VARCHAR2)
AUTHID CURRENT_USER
AS

  v_ret_msg                 VARCHAR2(255);
  v_sql                     VARCHAR2(4000);
  v_step                    NUMBER;

  -- Cursor to get all objects in the red schema to have synonyms created for them.
  CURSOR c_red_objects IS
  SELECT object_name
  FROM   all_objects
  WHERE  object_type IN ('TABLE','VIEW','FUNCTION','PROCEDURE','PACKAGE','SEQUENCE')
  AND    owner = p_red_schema;

  object_already_exists exception;
  pragma exception_init(object_already_exists,-00955);

BEGIN

  v_step := 10;

  -- Loop on objects and create synonyms.
  FOR r_red_objects IN c_red_objects LOOP

    v_step := 20;

    v_sql := 'CREATE SYNONYM '||r_red_objects.object_name||' FOR '||p_red_schema||
             '.'||r_red_objects.object_name;

    BEGIN
      EXECUTE IMMEDIATE v_sql;
      --DBMS_OUTPUT.put_line(v_sql);
    EXCEPTION
      WHEN object_already_exists THEN
        NULL;
    END;

  END LOOP;

  v_step := 30;

  v_ret_msg := 'Synonyms Created Sucessfully';
  DBMS_OUTPUT.put_line(v_ret_msg);

  RETURN;

EXCEPTION

  WHEN OTHERS THEN

     v_ret_msg := 'Unexpected Error in ws_seperate_meta_data.create_synonyms, step '||
                  v_step||' '||SQLERRM;

     DBMS_OUTPUT.put_line(v_ret_msg);

     ROLLBACK;

     RETURN;

END ws_sep_meta_data_create_syns;
/


