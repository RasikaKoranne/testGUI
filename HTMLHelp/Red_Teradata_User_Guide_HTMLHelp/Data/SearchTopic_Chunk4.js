define({"303":{y:0,u:"../Content/User Guide/Exporting Data/Script based Exports.htm",l:-1,t:"Script Based Exports",i:0.00085884420954181,a:"A script based export object will have a Host Script defined. During the export process, the host script is executed and the results returned. During the drag and drop creation of an export object from a single table or view, a script can be generated by selecting one of the \u0027Script based\u0027 export ..."},"304":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedures and Scripts.htm",l:-1,t:"Procedures and Scripts",i:0.00174402912935614,a:"WhereScape RED has a Procedure object group for database stored procedures and a Script object group for host system scripts, such as UNIX shell scripts or Windows batch files. Procedures WhereScape RED generates the bulk of the procedures during a prototype build, but these procedures can be ..."},"305":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Generation.htm",l:-1,t:"Procedure Generation",i:0.00085884420954181,a:"WhereScape RED generates template procedures to assist in the various phases of the data warehouse build process. A procedure is generated by selecting the (Build Procedure...) option from a drop-down list field in a table\u0027s Properties window to configure the update, initial build, or post load ..."},"306":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Editing.htm",l:-1,t:"Procedure Editing",i:0.00085884420954181,a:"WhereScape RED includes a procedure editor which allows the maintenance of the various procedures, functions and packages within the data warehouse. The editor is invoked by double-clicking on a procedure name in the left pane or by right-clicking on the procedure name and selecting Edit the ..."},"307":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Loading and Saving.htm",l:-1,t:"Procedure Loading and Saving",i:0.00085884420954181,a:"Procedures are normally stored in the WhereScape RED metadata tables. When a procedure is opened within WhereScape RED then the data is retrieved from the meta tables. Likewise when the procedure is saved, it overwrites the existing data in the meta tables. When a procedure is compiled, it is also ..."},"308":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Comparisons.htm",l:-1,t:"Procedure Comparisons",i:0.00085884420954181,a:"A procedure can be compared to either an earlier version, or to the currently running code as compiled/stored in the database. The menu option Tools \u003e Compare to Compiled Source enables the comparison of the procedure being edited with the code currently compiled and running in the database. If a ..."},"309":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Compilation.htm",l:-1,t:"Procedure Compilation",i:0.00122386598122782,a:"From within the procedure editor a procedure can be compiled by selecting the menu option Compile \u003e Compile or by clicking the Compile icon. If the procedure compiles successfully, a window appears confirming a successful compile. If the compile fails, then error message comments are inserted into ..."},"310":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Running.htm",l:-1,t:"Procedure Running",i:0.00085884420954181,a:"Only procedures that conform to the WhereScape RED scheduler syntax can be executed from within the procedure editor. Select the Execute \u003e Execute menu option or click the Execute icon to run the procedure. A procedure must have been compiled in order to run.   The results of the procedure is ..."},"311":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Syntax.htm",l:-1,t:"Procedure Syntax",i:0.00085884420954181,a:"The procedures managed by the WhereScape RED scheduler require the following standards. If a function or procedure is being developed that is not called directly by the scheduler, then it does not need to conform with this standard. If however, such a procedure or function wants to log messages to ..."},"312":{y:0,u:"../Content/User Guide/Procedures and Scripts/Procedure Properties.htm",l:-1,t:"Procedure Properties",i:0.00886613670533742,a:"The Properties screen for procedures and scripts is the same. A procedure can be renamed by changing the name field.  If a procedure is renamed, then it is also necessary to change the procedure name within the actual code. The Purpose and Owner fields are purely informational. In the above example, ..."},"313":{y:0,u:"../Content/Teradata/Procedures and Scripts/Macros.htm",l:-1,t:"Macros",i:0.00085884420954181,a:"WhereScape RED can also retrofit, run, schedule and generate Teradata macros. Template macros can be generated for moving data into simple staging tables without surrogate keys. A macro is generated by selecting the *** Create New Macro *** option from a drop-down box that is used to display the ..."},"314":{y:0,u:"../Content/Teradata/Procedures and Scripts/BTEQ Scripts.htm",l:-1,t:"BTEQ Scripts",i:0.00085884420954181,a:"WhereScape RED can also retrofit, run, schedule and generate Teradata BTEQ scripts. Template bteq scripts can be generated for moving data into simple staging tables without surrogate keys. A BTEQ script is generated by selecting the *** Create New Bteq *** option from a drop-down box that is used ..."},"315":{y:0,u:"../Content/User Guide/Procedures and Scripts/Script Generation.htm",l:-1,t:"Script Generation",i:0.00153414873411244,a:"WhereScape RED generates template scripts to assist in the loading of textual files from UNIX or Windows. These scripts are generated when a UNIX or Windows file is dragged into a Load table target and one of the \u0027Script based\u0027 file load options is chosen. Typically, script loads are used when some ..."},"316":{y:0,u:"../Content/Teradata/Procedures and Scripts/Script Generation (Windows_Teradata).htm",l:-1,t:"Script Generation (Windows/Teradata)",i:0.00085884420954181,a:"A sample Windows script for Teradata is as follows. The key components of the script are described below: The script makes use of a number of environmental variables. These variable are acquired from both the table and connection properties. These variables are established in the environment by ..."},"317":{y:0,u:"../Content/User Guide/Procedures and Scripts/Windows PowerShell Scripts.htm",l:-1,t:"Windows PowerShell Scripts",i:0.0110947094426485,a:"In addition to the conventional Windows scripting and other tools, WhereScape RED also supports Windows PowerShell scripts for loading data into a WhereScape RED managed Data Warehouse, as well as for exporting data from a WhereScape RED managed Data Warehouse.   The Windows PowerShell command line ..."},"318":{y:0,u:"../Content/User Guide/Procedures and Scripts/Script Editing.htm",l:-1,t:"Script Editing",i:0.00085884420954181,a:"WhereScape RED includes a script editor which allows the maintenance of any host scripts within the data warehouse. The editor is invoked by double-clicking on a script name in the left pane or by right-clicking the script name and then selecting Edit the Script from the context menu. Similar to the ..."},"319":{y:0,u:"../Content/User Guide/Procedures and Scripts/Script Testing.htm",l:-1,t:"Script Testing",i:0.00085884420954181,a:"When a host script is scheduled, it is run in the scheduler environment. Therefore a UNIX scheduler must be available to run a UNIX script and only a Windows scheduler can run a Windows script. It is possible to test a script interactively. For a Windows script, this is achieved by running the ..."},"320":{y:0,u:"../Content/User Guide/Procedures and Scripts/Script Syntax.htm",l:-1,t:"Script Syntax",i:0.00085884420954181,a:"There are a number of conventions that must be followed if a host script is to be used by the WhereScape scheduler. These conventions are: The first line of data in \u0027standard out\u0027 must contain the resultant status of the script. Valid values are \u00271\u0027 to indicate success, \u0027-1\u0027 to indicate a warning ..."},"321":{y:0,u:"../Content/User Guide/Procedures and Scripts/Script Environment Variables.htm",l:-1,t:"Script Environment Variables",i:0.00085884420954181,a:"The following environment variables are available for all script loads and script exports, both Windows and UNIX/Linux. All load scripts The following variables are available in all load scripts:   All load scripts from Database or ODBC connections In addition to the variables in the previous table, ..."},"322":{y:0,u:"../Content/User Guide/Procedures and Scripts/Calling a Batch File from a Script.htm",l:-1,t:"Calling a Batch File from a Script",i:0.00085884420954181,a:"Calling a Batch File from a Script Below is an example RED host script which calls a batch file: Where \"c:\\temp\\MyBatchFile.bat\" contains this: Create the Host Script in RED: Edit the Script and enter the following: Save the Script: When the script is executed, you will see the following results:  "},"323":{y:0,u:"../Content/User Guide/Procedures and Scripts/Scheduling Scripts.htm",l:-1,t:"Scheduling Scripts",i:0.00085884420954181,a:"When a host script is scheduled, it is run in the scheduler environment. Therefore, a UNIX scheduler must be available to run a UNIX script and only a Windows scheduler can run a Windows script. It is important to set the connection on the Properties screen for the script.  Right-click on the host ..."},"324":{y:0,u:"../Content/User Guide/Procedures and Scripts/Manually Created Scripts.htm",l:-1,t:"Manually Created Scripts",i:0.00085884420954181,a:"Individual scripts can also be manually created in RED to perform and schedule tasks that are not related to load tables. The example below shows a minimal script that will run successfully.  Please note that you need to use the following codes to determine the script\u0027s results meaning. It is ..."},"325":{y:0,u:"../Content/User Guide/Templates/Templates.htm",l:-1,t:"Templates",i:0.00298686735607314,a:"Templates provide the ability to customize automatically generated code within RED. This feature is most suited to users that would like to customize automatically generated code or would like to expand RED to support non-native database platforms. Creating templates is an advanced function that ..."},"326":{y:0,u:"../Content/User Guide/Templates/Template Properties.htm",l:-1,t:"Template Properties",i:0.00153414873411244,a:"The properties screen for a template is shown below. Name, Purpose and Author fields should be completed to provide background information on the template; these fields are purely informational. Created and Last Update fields provide date information on the template. The Target DB sets the type of ..."},"327":{y:0,u:"../Content/User Guide/PebbleTemplate/Pebble Templates.htm",l:-1,t:"Pebble Templates",i:0.00136663075106642,a:"Pebble is a scripting language that generates text output, based on provided meta data. The usage of Pebble templates in WhereScape RED does not require knowledge of Java. When looking at the Pebble documentation  ignore the references to Java, including information about setting up Pebble in Java. ..."},"328":{y:0,u:"../Content/User Guide/PebbleTemplate/RED_Template_API.html",l:-1,t:"Pebble Templates",i:0.00558488231654695,a:"Operation Types Create DDL env\n             table\n             options\n             settings\n             Types\n             Custom Procedure env\n             table\n             options\n             settings\n             Types\n             Export Script env\n             table\n             options\n   ..."},"329":{y:0,u:"../Content/User Guide/Templates/Template Editor.htm",l:-1,t:"Template Editor",i:0.00085884420954181,a:"Right-click a template and select Edit the Template or View Template to open the Template editor. Similar to the procedure and script editors, the template editor includes the following features: Pebble syntax highlighting \timproved find feature (repeated find, up and down, etc.) \ttoggle the display ..."},"330":{y:0,u:"../Content/User Guide/Templates/Evaltng API Outline Temp.htm",l:-1,t:"Evaluating an API Outline Template",i:0.00085884420954181,a:"An API Outline Template is available to output all object properties relevant to the current object. Upon evaluation of this template, the status of each property is generated and printed to the script or procedure file. To evaluate an API Outline Template: Create a new template. The template can ..."},"331":{y:0,u:"../Content/User Guide/PebbleTemplate/Pebble_Syntax.html",l:-1,t:"Pebble Syntax",i:0.00136663075106642,a:"Pebble Syntax Controls"},"332":{y:0,u:"../Content/User Guide/PebbleTemplate/PebbleTemplate_Tags.htm",l:-1,t:"Pebble Template Tags",i:0.00085884420954181,a:"autoescape The autoescape tag can be used to temporarily disable/re-enable the autoescaper as well as change the escaping strategy for a portion of the template. block A section that can be overridden by a child template. extends The extends tag is used to declare a parent template. It should be the ..."},"333":{y:0,u:"../Content/User Guide/PebbleTemplate/PebbleTemplate_Functions.htm",l:-1,t:"Pebble Template Functions",i:0.00085884420954181,a:"block The block function is used to render the contents of a block tag more than once. max The max function will return the largest of it\u0027s numerical arguments. min The min function will return the smallest of it\u0027s numerical arguments. parent The parent function is used inside of a block to render ..."},"334":{y:0,u:"../Content/User Guide/PebbleTemplate/PebbleTemplate_Filters.htm",l:-1,t:"Pebble Template Filters",i:0.00085884420954181,a:"abbreviate The abbreviate filter will abbreviate a string using an ellipsis. It takes one argument which is the max width of the desired output including the length of the ellipsis. abs The abs filter is used to obtain the absolute value. capitalize The capitalize filter will capitalize the first ..."},"335":{y:0,u:"../Content/User Guide/PebbleTemplate/PebbleTemplate_Tests.htm",l:-1,t:"Pebble Template Tests",i:0.00085884420954181,a:"defined The defined test checks if a variable exists. empty The empty test checks if a variable is empty. A variable is empty if it is null, an empty string, an empty collection, or an empty map. even The even test checks if an integer is even. iterable The iterable test checks if a variable ..."},"336":{y:0,u:"../Content/User Guide/PebbleTemplate/PebbleTemplate_Variables.htm",l:-1,t:"Pebble Template Variables",i:0.00085884420954181,a:"Pebble Template Variables StringUtil Provides common string function support.    "},"337":{y:0,u:"../Content/User Guide/Templates/Template Usage.htm",l:-1,t:"Template Usage",i:0.00151088558097499,a:"Template Usage If a template exists of the correct Type and Target DB, templates can be specified and evaluated as follows: To check which Operations are supported by Templates on your Target database, refer to  Templates  for details.  "},"338":{y:0,u:"../Content/User Guide/Templates/Windows PowerShell Templates.htm",l:-1,t:"Windows PowerShell Templates",i:0.00085884420954181,a:"PowerShell Stub Template (wsl_common_powershellscript_stub) You can use the basic PowerShell stub template available in WhereScape RED that serves as a guide in using a template to generate a PowerShell script.  Additional PowerShell Templates can be downloaded from the WhereScape website ( ..."},"339":{y:0,u:"../Content/User Guide/Scheduler/Scheduler.htm",l:-1,t:"Scheduler",i:0.00527470978590491,a:"The scheduler is accessible by clicking the Scheduler button   from the toolbar. It is also available as a stand alone utility. In this way, operators can be given access to the scheduler without gaining full access to the data warehouse. The scheduler runs on either a UNIX host or under Windows (as ..."},"340":{y:0,u:"../Content/User Guide/Scheduler/Scheduler Options.htm",l:-1,t:"Scheduler Window",i:0.00085884420954181,a:"An example of the Scheduler screen is shown below. Toolbar/Jobs menu Quick access to some job categories are in the toolbar. The complete options are listed under the Jobs menu and while most are self-explanatory they are described below: Top pane The top pane shows the details of the jobs. ..."},"341":{y:0,u:"../Content/User Guide/Scheduler/Auto Menu.htm",l:-1,t:"Auto Menu",i:0.00085884420954181,a:"Auto Menu The Auto menu provides options for refreshing the scheduler display. The following options are available:  "},"342":{y:0,u:"../Content/User Guide/Scheduler/Tools.htm",l:-1,t:"Tools Menu",i:0.00085884420954181,a:"Tools Menu The Tools menu provides options for configuring the scheduler display. The following options are available:  "},"343":{y:0,u:"../Content/User Guide/Scheduler/Select Job Report Fields.htm",l:-1,t:"Select Job Report Fields",i:0.00085884420954181,a:"The Select Job Report Fields menu option in the Scheduler window enables you to select extra fields (e.g. Scheduler, Threads and Frequency) to include in the job report. such as  fields into the job report.  To make these fields available, click Tools \u003e Select job report fields from the top pane. ..."},"344":{y:0,u:"../Content/User Guide/Scheduler/Scheduler States.htm",l:-1,t:"Scheduler States",i:0.00085884420954181,a:"Scheduler States A scheduled job can have the following states: Hold Waiting Blocked Pending Running Failed Failed - Aborted Completed   A scheduled task can have the following states: Waiting or Blank Held Running Failed Completed Error Completion Bad Return Status  "},"345":{y:0,u:"../Content/User Guide/Scheduler/Scheduling a Job.htm",l:-1,t:"Scheduling a Job",i:0.00859002065028221,a:"Open the Scheduler by clicking the Scheduler button  from the  toolbar.  Click File \u003e New Job from the menu in the top of the screen, or click the New Job button from the toolbar. Enter the required details in the Job Definition window. Refer to  Creating a Job  for more details on how to create a ..."},"346":{y:0,u:"../Content/User Guide/Scheduler/Working with Jobs.htm",l:-1,t:"Working with Jobs",i:0.00085884420954181,a:"When you right click a Job in the Scheduler window, the context menu provides several options for working with the job.   You can also access and manage the scheduler jobs from the Objects list pane of the Builder window. Some of the options are discussed in more detail in the succeeding sections, ..."},"347":{y:0,u:"../Content/User Guide/Scheduler/Creating a Job.htm",l:-1,t:"Creating a Job",i:0.013002566808652,a:"Click the Scheduler tab to open the Scheduler window. Click the New Job button to create a new job. A Job Definition window is displayed.  Complete the fields and then click OK. The main fields are described in the following table: The following fields are available if a frequency of Custom is ..."},"348":{y:0,u:"../Content/User Guide/Scheduler/Editing a Job.htm",l:-1,t:"Editing a Job",i:0.00100485291821622,a:"Once jobs have been created they can be edited. To edit a job Select the job from the middle pane and then right-click to select Edit Job from the context menu. The Job Definition is displayed. Edit the fields as required and click OK. The main fields are described in the following table: The ..."},"349":{y:0,u:"../Content/User Guide/Scheduler/Editing Tasks in a Job.htm",l:-1,t:"Editing Tasks in a Job",i:0.00203715939070914,a:"Once jobs have been created, you can edit their tasks.   To edit the tasks of a job Select the job from the middle pane and then right-click the job to select Edit Tasks from the context menu. The Define tasks window is displayed. The screen has two main areas. The right pane shows the tasks to be ..."},"350":{y:0,u:"../Content/User Guide/Scheduler/Editing Task Dependencies.htm",l:-1,t:"Editing Task Dependencies",i:0.00100485291821622,a:"Once jobs have been created they can be edited.   To edit task dependencies Select the job from the middle pane and then right-click to select Edit Dependencies from the context menu. The Dependencies window is displayed, showing the dependencies between the tasks of the job. The list consists of ..."},"351":{y:0,u:"../Content/User Guide/Scheduler/Show Dependencies Diagram.htm",l:-1,t:"Show Dependencies Diagram",i:0.00085884420954181,a:"Show Dependencies Diagram Select the Show Dependency Diagram option from the right-click menu of any job, to see all job dependencies displayed as a Diagram from RED\u0027s Diagram view tab. Job Dependency Diagram view"},"352":{y:0,u:"../Content/User Guide/Scheduler/Inserting a Copy of a Job.htm",l:-1,t:"Inserting a Copy of a Job",i:0.000931848563879013,a:"Inserting a Copy of a Job A copy of a job can be inserted by right-clicking the job and choosing Insert Copy of Job from the context menu. The new job is immediately visible and the Status is On Hold.  "},"353":{y:0,u:"../Content/User Guide/Scheduler/Deleting a Job.htm",l:-1,t:"Deleting a Job",i:0.000931848563879013,a:"Deleting a Job A job can be deleted by right-clicking the job in the Scheduler window and then choosing Delete Job from the context menu. A confirmation prompt is displayed; click Yes to delete. "},"354":{y:0,u:"../Content/User Guide/Scheduler/Deleting Job Logs.htm",l:-1,t:"Deleting Job Logs",i:0.000931848563879013,a:"Multiple job logs can be deleted by right-clicking a job in the Scheduler window and then choosing Multiple Log Delete from the context menu. The Delete Multiple Job Logs window is displayed. Select or enter the appropriate options to delete the range of job logs required. A confirmation prompt is ..."},"355":{y:0,u:"../Content/User Guide/Scheduler/Starting a Job.htm",l:-1,t:"Starting a Job",i:0.000931848563879013,a:"Starting a Job A job can be started by right-clicking the job in the Scheduler window and then choosing Start the Job from the context menu."},"356":{y:0,u:"../Content/User Guide/Scheduler/Halting a Job.htm",l:-1,t:"Halting a Job",i:0.000931848563879013,a:"Halting a Job A job can be halted by right-clicking the job in the Scheduler window and then choosing Halt the Job from the context menu."},"357":{y:0,u:"../Content/User Guide/Scheduler/Aborting a Job.htm",l:-1,t:"Aborting a Job",i:0.000931848563879013,a:"Aborting a Job A job can be aborted by right-clicking the job in the Scheduler window and choosing Abort Job from the context menu. Once in this state, a job cannot be restarted. The job now only exists as a log of what occurred and is no longer regarded as a job.  "},"358":{y:0,u:"../Content/User Guide/Scheduler/Effects of Aborting a Job.htm",l:-1,t:"Effects of Aborting a Job",i:0.00085884420954181,a:"Effects of Aborting a Job Load and update processes are not stopped for all objects in Teradata repositories.  "},"359":{y:0,u:"../Content/User Guide/Scheduler/Restarting a Job.htm",l:-1,t:"Restarting a Job",i:0.000931848563879013,a:"A job can be restarted by right-clicking the job in the Scheduler window and choosing Restart the Job from the context menu. Before restarting a job, it is possible to edit the status of the job tasks so that only certain tasks will be run again or be skipped over. To run a task again View the job ..."},"360":{y:0,u:"../Content/User Guide/Scheduler/Creating an Application from a Job.htm",l:-1,t:"Creating an Application from a Job",i:0.00085884420954181,a:"Right-click the job in the Scheduler window and then select Create Application from the context menu. Edit the application details as required. Edit the objects to add or replace as required. Click OK when finished. A message window appears, confirming the creation of the application files. Click ..."},"361":{y:0,u:"../Content/User Guide/Scheduler/Stand Alone Scheduler Maintenance.htm",l:-1,t:"Stand Alone Scheduler Maintenance",i:0.00085884420954181,a:"WhereScape RED includes a stand alone scheduler maintenance screen. This screen provides all the scheduler control functionality found in the main WhereScape RED utility, but with no access to the main metadata repository. Scheduler maintenance logon The logon screen differs in that the user name ..."},"362":{y:0,u:"../Content/User Guide/Scheduler/SQL to return Scheduler Status.htm",l:-1,t:"SQL to return Scheduler Status",i:0.00085884420954181,a:"SQL to return Scheduler Status This SQL returns the scheduler status: The procedure sets the status in the metadata. "},"363":{y:0,u:"../Content/User Guide/Scheduler/Reset Columns in Job and Task.htm",l:-1,t:"Reset Columns in Job and Task View",i:0.00085884420954181,a:"Job and Task Report headings can be reset by selecting the View \u003e Reset Display Headings menu option from the Scheduler window. The short-cut keys are Alt+V-R. A message prompt asks you to confirm the request. Select Yes to reset the display settings, a message is displayed to confirm the reset has ..."},"364":{y:0,u:"../Content/User Guide/Scheduler/Stopping a Linux UNIX Scheduler.htm",l:-1,t:"Stopping a Linux/UNIX Scheduler from within RED",i:0.00085884420954181,a:"To stop a Linux/UNIX Scheduler from within RED, follow the steps below: Edit the crontab and comment out the ws_sched_check_nnn.sh entry. This will stop the scheduler restarting within the next 20 minutes. Start RED and click the Scheduler tab. Click the Scheduler menu from the toolbar and then ..."},"365":{y:0,u:"../Content/User Guide/Indexes/Indexes.htm",l:-1,t:"Indexes",i:0.00179264627193921,a:"Indexes may exist on any table defined in WhereScape RED.  By default, WhereScape RED will auto-generate a number of indexes during the drag and drop process to create new table objects and when building procedures.  The Enable Automatic Creation of Indexes option in the Connection Properties window ..."},"366":{y:0,u:"../Content/User Guide/Indexes/Index Definition.htm",l:-1,t:"Index Definition",i:0.00085884420954181,a:"Right-clicking a table in the left pane and selecting Display Indexes from the context menu lists the indexes for the table in the middle pane. Alternatively, you can double-click the Index object type in the left pane, to display all indexes in the repository or a specific group or project. In the ..."},"367":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Documentation and Diagrams.htm",l:-1,t:"Documentation and Diagrams",i:0.00264967472573687,a:"WhereScape RED includes the ability to document the data warehouse based on the information stored against the metadata for all the tables and columns in the data warehouse. The documentation will only be meaningful if information is stored in the metadata. The business definition and a description ..."},"368":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Creating Documentation.htm",l:-1,t:"Creating Documentation",i:0.00168263048931027,a:"To create the documentation for the components of the data warehouse, click Doc from the Builder window menu, then click Create Documentation.   If the repository has Projects or Groups in use, then the following window appears to allow the selection of a specific group or project. The default is ..."},"369":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Batch Documentation Creation.htm",l:-1,t:"Batch Documentation Creation",i:0.00085884420954181,a:"WhereScape RED includes the ability to document the data warehouse, based on the information stored against the metadata for all the tables and columns in the data warehouse. In a larger environment, it may be a good idea to generate documentation in batch mode. The following syntax chart ..."},"370":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Reading the Documentaion.htm",l:-1,t:"Reading the Documentation",i:0.00168263048931027,a:"Reading the Documentation To read the documentation you have created, select Doc from the builder menu bar, then Read Documentation. This will launch a browser and display the contents of index.html. Alternatively you can access the HTML pages directly from their saved location.    "},"371":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Diagrams.htm",l:-1,t:"Diagrams",i:0.00174402912935614,a:"Diagrams  "},"372":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Types of Diagrams.htm",l:-1,t:"Types of Diagrams",i:0.00085884420954181,a:"Six types of diagrams are provided to give visual representation of what has been created. These are The  Schema Diagram   The  Source Diagram The  Joins Diagram The  Links Diagram The  Impact Diagram The  Dependency Diagram To display the Diagram Selection window, click the New Diagram button   ..."},"373":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Schema Diagram.htm",l:-1,t:"Schema Diagram",i:0.000963136144309242,a:"A star schema diagram can be displayed for a fact table, an aggregate table and an OLAP cube. It shows the central table with the outlying dimensions.  An example of a Schema diagram in Standard Diagram format is displayed below. An example of a Schema diagram in Detail Diagram format is displayed ..."},"374":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Source Diagram.htm",l:-1,t:"Source Diagram",i:0.000963136144309242,a:"A source tracking diagram can be displayed for any table. It shows connections back from the chosen table to the source tables from which information was derived. Hovering the cursor over a line shows additional information. For lines going into Load tables, the source of the data is displayed; ..."},"375":{y:0,u:"../Content/User Guide/Documentation and Diagrams/Joins Diagram.htm",l:-1,t:"Joins Diagram",i:0.000963136144309242,a:"A data join track back diagram can be displayed for any table. It shows connections back from the chosen table to the source tables from which information was derived and includes Dimension table joins. Hovering the cursor over a line shows additional information. For lines going into Load tables, ..."},});