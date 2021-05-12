--  
  BULK INSERT  
    dbo.load_employee 
  FROM  
    "wsl_load_employee_434938593.dat" 
  WITH 
  ( 
TABLOCK 
, DATAFILETYPE='char' 
, CODEPAGE='raw' 
, FIELDTERMINATOR = '|' 
, MAXERRORS=0 
  ) 
select convert(varchar,@@rowcount) + ' Rows successfully loaded.' 
exit(SELECT @@ERROR) 
