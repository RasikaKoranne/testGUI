@echo off

REM *********************************************************************************************
REM * 
REM * This file is an example for loading the WhereScape Tutorial #1 to repository WslWarehouse
REM * 
REM * The first step performed is to provide a restore point (application) that can be 
REM * applied as a standard application load if at some point need to restore to prior 
REM * to that application load for the objects contained in this application load.
REM *
REM * The second step loads the actual application to the target WhereScape RED repository.
REM * 
REM *********************************************************************************************


REM *********************************************************************************************
REM * First create 'restore point' application based on objects about to be loaded.
REM *********************************************************************************************
"C:\Program Files\WhereScape\med" /BA /C "WslWarehouse" /D "C:\ProgramData\WhereScape\Application\"  /I "PRE_SQLT" /V "tutorial_1" /AF "C:\ProgramData\WhereScape\Application\app_id_SQLT_tutorial_1.wst"


REM *********************************************************************************************
REM * Now apply the application to the target repository
REM *********************************************************************************************
"C:\Program Files\WhereScape\adm" /AL /AF "C:\ProgramData\WhereScape\Application\app_id_SQLT_tutorial_1.wst" /LF "C:\ProgramData\WhereScape\Application\app_SQLT_tutorial_1.log" /PF "C:\ProgramData\WhereScape\Application\WSL_Application_Load.xml"

$exit


REM *********************************************************************************************
REM **** Batch Application CREATE options
REM *********************************************************************************************

REM /BA selects batch application create
REM /U username.
REM /P password.
REM /C DSN name.
REM /M metaschema/database for DB2/Teradata logon
REM /D directory to save application files to.
REM /I new application files identifier
REM /V new application files version.
REM /AF absolute application id file name which restore point is being created for.
REM If a trusted connection, the user and password are not necessary.


REM *********************************************************************************************
REM **** Batch Application LOAD options
REM *********************************************************************************************

REM /AL select application load
REM /AF absolute application id file name
REM /LF absolute log file name
REM /PF absolute xml parameter file name

REM *********************************************************************************************

