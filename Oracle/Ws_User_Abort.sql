CREATE OR REPLACE PROCEDURE sys.Ws_User_Abort
( p_sid         IN  NUMBER
, p_serial_no   IN  NUMBER
, p_return_msg  OUT VARCHAR2
, p_status_code OUT NUMBER)
AS

-- =============================================================================
-- DBMS Name 	    	:	Oracle
-- Script Name 		:	Ws_User_Abort
-- Description 		:	Kill a user session
-- WhereScape Limited, inc. All rights reserved. (C) Copyright 1996-2002
-- =============================================================================
-- Notes / History
--
-- JML 16/11/2005  Version 1.0.0]
--

  v_sql VARCHAR2(4000);

BEGIN
 
  v_sql := 'ALTER SYSTEM KILL SESSION '''||p_sid||', '||p_serial_no||'''';

  BEGIN
    EXECUTE IMMEDIATE v_sql;
    p_return_msg := 'Session Killed.';
    p_status_code := 1;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -31 THEN -- Session marked for kill
        p_return_msg := SQLERRM;
        p_status_code := 1;
      ELSE
        p_return_msg := 'Unhandled Exception '||SQLCODE||' in Ws_User_Abort. '||SQLERRM;
        p_status_code := -3;
      END IF;
  END;

  COMMIT;

END;
