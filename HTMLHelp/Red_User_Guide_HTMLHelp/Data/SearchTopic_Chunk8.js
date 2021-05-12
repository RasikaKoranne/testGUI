define({"630":{y:0,u:"../Content/User Guide/Ws_admin_v Views/Ws_admin_v_dim_col.htm",l:-1,t:"Ws_admin_v_dim_col",i:0.000737535493508448,a:"Ws_admin_v_dim_col This Dimension Column view is created from the ws_dim_tab and ws_dim_col tables. Columns The following columns are created: SQL Script"},"631":{y:0,u:"../Content/User Guide/Ws_admin_v Views/Ws_admin_v_error.htm",l:-1,t:"Ws_admin_v_error",i:0.000737535493508448,a:"Ws_admin_v_error This Error view is created using columns from the ws_wrk_error_log table. Columns The following columns are created: SQL Script"},"632":{y:0,u:"../Content/User Guide/Ws_admin_v Views/Ws_admin_v_fact_col.htm",l:-1,t:"Ws_admin_v_fact_col",i:0.000737535493508448,a:"Ws_admin_v_fact_col This Fact Column view is created from the ws_fact_tab and ws_fact_col tables. Columns The following columns are created: SQL Script"},"633":{y:0,u:"../Content/User Guide/Ws_admin_v Views/Ws_admin_v_fact_join.htm",l:-1,t:"Ws_admin_v_fact_join",i:0.000737535493508448,a:"Ws_admin_v_fact_join This Fact Column view is created from the ws_fact_tab and ws_fact_col tables. Columns The following columns are created: SQL Script    "},"634":{y:0,u:"../Content/User Guide/Ws_admin_v Views/Ws_admin_v_sched.htm",l:-1,t:"Ws_admin_v_sched",i:0.000737535493508448,a:"Ws_admin_v_sched This Scheduled Job view is created from the ws_wrk_job_log table. Columns The following columns are created: SQL Script  "},"635":{y:0,u:"../Content/User Guide/Ws_admin_v Views/Ws_admin_v_task.htm",l:-1,t:"Ws_admin_v_task",i:0.000737535493508448,a:"Ws_admin_v_task This Task view is created from the ws_wrk_task_run and ws_wrk_task_log tables. Columns The following columns are created: SQL Script  "},"636":{y:0,u:"../Content/User Guide/Retrofitting/Retrofitting.htm",l:-1,t:"Retrofitting",i:0.000737535493508448,a:"WhereScape RED includes an advanced retrofit capability that can be used to: Migrate an existing data warehouse from one relational database to another (known as fork-lifting). Load a data model from a modeling tool. Retrofitting is achieved using the Retro object type in WhereScape RED and the ..."},"637":{y:0,u:"../Content/User Guide/Retrofitting/Migrating the Data Warehouse Database Platform.htm",l:-1,t:"Migrating the Data Warehouse Database Platform",i:0.000946511108667058,a:"WhereScape RED has an advanced retrofitting wizard for migrating an existing data warehouse from one relational database to another. The process to migrate an existing data warehouse includes: Creating a connection object to the existing warehouse database. Creating Retro objects based on the source ..."},"638":{y:0,u:"../Content/User Guide/Retrofitting/Importing a Data Model.htm",l:-1,t:"Importing a Data Model",i:0.00131221843519463,a:"WhereScape RED provides functionality for importing data models from modeling tools. The process to import a model is: Create the physical data model in the modeling tool. Generate DDL for the physical model in the modeling tool. Run the DDL in the data warehouse database to create empty versions of ..."},"639":{y:0,u:"../Content/User Guide/Retrofitting/Re Targeting Source Tables.htm",l:-1,t:"Re-Targeting Source Tables",i:0.00100572351219749,a:"Objects that have been retrofitted into the WhereScape RED meta data have themselves as their source table: They can be re-targeted to the correct source table(s) using the WhereScape RED re-target wizard as follows. Right-click a table object in the left pane and select Change Column(s). Select the ..."},"640":{y:0,u:"../Content/User Guide/Retrofitting/Retro Column Properties.htm",l:-1,t:"Retro Column Properties",i:0.000737535493508448,a:"Each Retro column has a set of associated properties. The definition of each property is defined below. If the Column name or Data type is changed for a column then the metadata will differ from the table as recorded in the database. Use the Validate \u003e Validate Table Create Status menu option to ..."},"641":{y:0,u:"../Content/User Guide/Retrofitting/Retro Column Properties Screen.htm",l:-1,t:"Retro Column Properties Screen",i:0.000737535493508448,a:"Retro Column Properties Screen A sample Properties screen is as follows:"},"642":{y:0,u:"../Content/User Guide/Retrofitting/Retro Column Transformations.htm",l:-1,t:"Retro Column Transformations",i:0.000737535493508448,a:"Retro Column Transformations It is possible to do transformations on Retro table columns. It is recommended that transformations are not performed on columns that are dimension keys or the business keys for the table. The transformation screen is as follows: Refer to  Transformations  for details.  "},"643":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrate WS RED in Exstng Warehse.htm",l:-1,t:"Integrating WhereScape RED into an Existing Warehouse",i:0.000737535493508448,a:"Two main options exist in terms of bringing WhereScape RED into an existing data warehouse environment: Rebuild tables and procedures with WhereScape RED. Integrating existing tables and procedures into WhereScape RED. Both options require manual coding changes to stored procedures. The main ..."},"644":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Rebuilding.htm",l:-1,t:"Rebuilding",i:0.00105099891624636,a:"The rebuild process essentially is a total re-creation of the data warehouse. One of the major impacts of such an approach is the end user layer, or rather the effect on the end user tools and saved queries and reports that are currently in use. The redesign or redeployment of this interface to the ..."},"645":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrating.htm",l:-1,t:"Integrating",i:0.00105099891624636,a:"The integrate process The steps in the integrate process are: Create a test environment (database user) with the existing data warehouse tables loaded. Load a copy of the WhereScape metadata repository into this test environment. Refer to the RED Installation Guide for instructions on how to load a ..."},"646":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrating Host Scripts.htm",l:-1,t:"Integrating, Host Scripts",i:0.000865161587988842,a:"Existing host scripts (either UNIX or Windows) can be brought into the WhereScape RED metadata. To incorporate an existing script the process is as follows: Create a Host Script object using WhereScape RED. In the left pane, right-click a project or the All Objects project and select New Object.  In ..."},"647":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrating Select a Tbl Type.htm",l:-1,t:"Integrating, Selecting a Table Type",i:0.000865161587988842,a:"When integrating existing tables there may not be a clear decision as to which table type to use. As a guideline, the following groupings can be considered. Temporary tables: Load tables Stage tables Permanent tables: Dimension tables Fact tables Aggregate tables Although these table groups have ..."},"648":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrating, Questions.htm",l:-1,t:"Integrating, Questions",i:0.000865161587988842,a:"When a table within the data warehouse schema, that is unknown to WhereScape RED, is dropped onto a table target the following dialog appears. If this is an integrate then click Yes to proceed with the integrate process. The standard New Object dialog appears and it would be advisable to leave the ..."},"649":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrating Procedures.htm",l:-1,t:"Integrating, Procedures",i:0.00186876399011727,a:"  The procedures managed by the WhereScape scheduler require the following standards. Parameters The procedure must have the following parameters in the following order: The input parameters are passed to the procedure by the scheduler. If the procedure is called outside the scheduler then the ..."},"650":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrating Views.htm",l:-1,t:"Integrating, Views",i:0.000737535493508448,a:"When integrating views an additional step is required if you want WhereScape RED to be able to recreate the view.   The view will be mapped correctly and the Get Key function can still be built. This step is only required if the view is to be re-created. Change the source column on the artificial ..."},"651":{y:0,u:"../Content/User Guide/Integrating into existing Warehouse/Integrating, WS Tables.htm",l:-1,t:"Integrating, WhereScape Tables",i:0.000737535493508448,a:"When integrating WhereScape generated tables and views a number of additional considerations need to be taken. The Dimension tables and views make use of secondary business key columns such as dss_source_system_key, dss_current_flag, dss_end_date, dss_version to assist in handling various forms of ..."},"652":{y:0,u:"../Content/User Guide/Relationship Maintenance/Relationship Maintenance.htm",l:-1,t:"Relationship Maintenance",i:0.00158397208218946,a:"Relationship Maintenance is available for the maintenance of joins between objects; providing a way to record joins between tables when surrogate keys are not being used. This functionality then enables the generation of Links Diagrams for these objects.  Relationship Maintenance options are ..."},"653":{y:0,u:"../Content/User Guide/Relationship Maintenance/Add Relationship.htm",l:-1,t:"Add Relationship",i:0.000737535493508448,a:"To add a relationship, right-click on the object in the Object Pane and select Relationships \u003e Add Relationships. The following window is displayed. For each object in the relationship, type in the following details: Once you have entered the details for the join, the joined columns are displayed in ..."},"654":{y:0,u:"../Content/User Guide/Relationship Maintenance/List Relationships.htm",l:-1,t:"List Relationships",i:0.000737535493508448,a:"To view relationship for an object, right-click the object from the Object Pane and select Relationships \u003e List Relationships. The relationships for the selected object are displayed in the Drop Target Pane (middle pane). Multi-column joins are shaded when one join is selected. Right-clicking on a ..."},"655":{y:0,u:"../Content/User Guide/Relationship Maintenance/Modify Relationship.htm",l:-1,t:"Modify Relationship",i:0.000737535493508448,a:"The Modify Relationship option shows the following window, which enables you to edit joins (including multi-column joins) between the two objects in the selected relationship.  Relationships are edited in this window in the same way as the Add Relationship window. Object Types and Table names cannot ..."},"656":{y:0,u:"../Content/User Guide/Relationship Maintenance/Delete Relationship.htm",l:-1,t:"Delete Relationship",i:0.000737535493508448,a:"Delete Relationship Deletes the selected relationship.    "},"657":{y:0,u:"../Content/User Guide/Relationship Maintenance/Generate Relationships.htm",l:-1,t:"Generate Relationships",i:0.000737535493508448,a:"Generate Relationships To generate relationships in metadata for an object, right-click the object from the Object Pane and select Relationships \u003e Generate Relationships. Results are shown in the Results Pane."},"658":{y:0,u:"../Content/User Guide/Upgrading RED.htm",l:-1,t:"Upgrading RED",i:0.000737535493508448,a:"WhereScape Versions WhereScape RED has a four part version number normally shown as xx.xx.xx.xx. An example of this may be 6.0.6.0. The first number represents the major release. The second number represents the metadata repository version. The third and fourth numbers relate to application specific ..."},"659":{y:0,u:"../Content/User Guide/Login Checks/Login Checks.htm",l:-1,t:"Login Checks",i:0.000737535493508448,a:"The following checks are performed during login; and if necessary, warning messages are displayed, see more about each specific warning by following the links below: Login Data Source does not match the data warehouse connection\u0027s ODBC DSN More than one connection has the data warehouse option ..."},"660":{y:0,u:"../Content/User Guide/Login Checks/Data Source not match the ODBC DSN.htm",l:-1,t:"Data Source does not match the data warehouse connection\u0027s ODBC DSN",i:0.000946511108667058,a:"Warning about the login Data Source not matching the data warehouse connection\u0027s ODBC DSN: You can correct this issue by performing one of the following actions: Alter the Data Warehouse Connection ODBC Data Source Name (DSN) to match the login Data Source. Logoff and log back in using the Data ..."},"661":{y:0,u:"../Content/User Guide/Login Checks/More connection DWenabled .htm",l:-1,t:"More than one connection has the Data Warehouse Indicator Enabled",i:0.000946511108667058,a:"More than one connection has the Data Warehouse Indicator Enabled Warning about more than one connection having the data warehouse option enabled. You can correct this issue by editing all the connections and making sure that only one is set to Data Warehouse:  "},"662":{y:0,u:"../Content/User Guide/Login Checks/Oracle Individual User.htm",l:-1,t:"Oracle Individual User",i:0.000946511108667058,a:"Oracle Individual User For any errors or for more information about logging in, or creating an Oracle Individual User, refer to Creating an Oracle Individual user for details in the WhereScape RED Installation Guide."},"663":{y:0,u:"../Content/User Guide/Data Type Mappings/Data Type Mappings.htm",l:-1,t:"Data Type Mappings",i:0.00136446233898428,a:"Using Data Type Mapping Sets Data type mapping sets contain a list of mappings that are used when loading tables into the data warehouse.  Custom data type mapping sets give you the ability to automatically change the data type of any column or to add column transformations when dragging and ..."},"664":{y:0,u:"../Content/User Guide/Data Type Mappings/Maintaining Data Type Mapping Sets.htm",l:-1,t:"Maintaining Data Type Mapping Sets",i:0.000737535493508448,a:"To maintain the data type mapping sets, select Tools \u003e Data Type Mappings \u003e Maintain Data Type Mappings. The Maintain Data Type Mapping Sets window is displayed. Select a data type mapping set from the Data Type Mapping Sets list.  In the list of standard files, only the files relevant to the ..."},"665":{y:0,u:"../Content/User Guide/Data Type Mappings/Creating a New Data Type Mapping Set.htm",l:-1,t:"Creating a New Data Type Mapping Set",i:0.000894267204877406,a:"To create a new data type mapping set, select Tools \u003e Data Type Mappings \u003e Maintain Data Type Mappings. Click the New button from the Maintain Data Type Mapping Sets window to enter the name and description of the new Mapping Set. You can then enter the individual data type mapping conversion ..."},"666":{y:0,u:"../Content/User Guide/Data Type Mappings/Copying a Data Type Mapping Set.htm",l:-1,t:"Copying a Data Type Mapping Set",i:0.000894267204877406,a:"To copy an existing data type mapping set, select Tools \u003e Data Type Mappings \u003e Maintain Data Type Mappings. Select the Mapping Set to be copied from the list in the Maintain Data Type Mapping Sets window and then click the Copy button. Change the name and description of the new Mapping Set as ..."},"667":{y:0,u:"../Content/User Guide/Data Type Mappings/Editing a Data Type Mapping Set.htm",l:-1,t:"Editing a Data Type Mapping Set",i:0.000894267204877406,a:"To edit a data type mapping set, select Tools \u003e Data Type Mappings \u003e Maintain Data Type Mappings. Select the Mapping Set to be modified from the list in the Maintain Data Type Mapping Sets window and then click the Edit button.  In the Data Type Mapping Set window, select the parameter you want to ..."},"668":{y:0,u:"../Content/User Guide/Data Type Mappings/Deleting a Data Type Mapping Set.htm",l:-1,t:"Deleting a Data Type Mapping Set",i:0.000894267204877406,a:"Deleting a Data Type Mapping Set To delete a data type mapping set, select Tools \u003e Data Type Mappings \u003e Maintain Data Type Mappings. Select the Mapping Set to be deleted and then click the Delete button.  A prompt is displayed asking you to confirm the action. Click Yes to proceed or No to cancel.  "},"669":{y:0,u:"../Content/User Guide/Data Type Mappings/Loading Custom Data Type Mapping Sets.htm",l:-1,t:"Loading Custom Data Type Mapping Sets",i:0.000737535493508448,a:"The Load Custom Data Type Mapping Set menu option enables you to load a custom data type mapping set from an XML file into the RED metadata repository. To load a data type mapping set, select Tools \u003e Data Type Mappings \u003e Load Custom Data Type Mapping Set. The following window is displayed. Select ..."},"670":{y:0,u:"../Content/User Guide/Data Type Mappings/Exporting Custom Data Type Mapping Sets.htm",l:-1,t:"Exporting Custom Data Type Mapping Sets",i:0.000737535493508448,a:"The Export Custom Data Type Mapping Set  menu option enables you to export a custom data type mapping set from the RED metadata repository to an XML file. To export a data type mapping set, select Tools \u003e Data Type Mappings \u003e Export Custom Data Type Mapping Set. Select the data type mapping set to ..."},"671":{y:0,u:"../Content/User Guide/Data Type Mappings/Custom Data Type Mapping Set Examples.htm",l:-1,t:"Custom Data Type Mapping Set Examples",i:0.00149769024692774,a:"WhereScape RED enables you to create Custom Data Type Mapping Sets. This gives you the ability to automatically change the data type of any column or to add column transformations, when dragging and dropping new Load tables. The examples in this topic demonstrate how Custom Data Type Mapping Sets ..."},"672":{y:0,u:"../Content/User Guide/Column Context Menu/Column Context Menu.htm",l:-1,t:"Column Context Menu",i:0.000737535493508448,a:"Column Context Menu To view the column context menu, click on an object in the left pane to display the columns in the middle pane. When positioned on a column in the middle pane, right-click on the column to bring up the menu.    "},"673":{y:0,u:"../Content/User Guide/Column Context Menu/Properties.htm",l:-1,t:"Properties",i:0.000737535493508448,a:"Properties To display the column Properties, right-click on a column in the middle pane and select Properties.  Edit any field as required and then click OK to close.  "},"674":{y:0,u:"../Content/User Guide/Column Context Menu/Change Column s.htm",l:-1,t:"Change Column(s)",i:0.0046334033210062,a:"To change the properties of multiple columns, right-click the columns in the middle pane and select Change Column(s). Select the relevant check boxes in the left pane to specify the properties to be changed. Selecting a check box enables you to change the value for that field in the column ..."},"675":{y:0,u:"../Content/User Guide/Column Context Menu/Add Column.htm",l:-1,t:"Add Column",i:0.000737535493508448,a:"Add Column To add a column, right-click on one of the columns in the middle pane and select Add Column.  Enter the details to define a new column and click OK.      "},"676":{y:0,u:"../Content/User Guide/Column Context Menu/Duplicate Column.htm",l:-1,t:"Duplicate Column",i:0.000737535493508448,a:"Duplicate Column To copy a column, right-click on one of the columns in the middle pane and select Duplicate Column.  Change the Column Name and the Business Display Name and any other properties to define a new column and click OK.      "},"677":{y:0,u:"../Content/User Guide/Column Context Menu/Delete Column.htm",l:-1,t:"Delete Column",i:0.000737535493508448,a:"Delete Column To delete a column, right-click on one of the columns in the middle pane and select Delete Column. Click Yes to continue with the delete.      "},"678":{y:0,u:"../Content/User Guide/Column Context Menu/Re space Order Number.htm",l:-1,t:"Re-space Order Number",i:0.000737535493508448,a:"Re-space Order Number To re-space the column order, right-click on any column in the middle pane and select Respace Order Number. The Column Order number for each column will be adjusted so that the column order numbers are evenly spaced.  "},"679":{y:0,u:"../Content/User Guide/Column Context Menu/Sync_Col_order_database.htm",l:-1,t:"Sync Column order with database",i:0.000737535493508448,a:"To synchronize the metadata\u0027s column order to match the same order in the physical table in the database: Right-click on one of the columns in the middle pane and select Sync the column order with the database. This will reorder the metadata columns to match the column order in the database table. "},"680":{y:0,u:"../Content/User Guide/Column Context Menu/Impact.htm",l:-1,t:"Impact",i:0.000737535493508448,a:"To display a Track Back Report, right-click on a column in the middle pane and select Impact \u003e Track Back Report. The report will be displayed in the bottom middle pane. This report lists the origins of the selected column. Refer to   Track Back Report  for details. To display a Track Forward ..."},"681":{y:0,u:"../Content/User Guide/Column Context Menu/Send_Col_Another Object.htm",l:-1,t:"Send Columns to Another Object",i:0.000737535493508448,a:"To send/copy columns to another object, right-click on a column in the middle pane and select Send Columns To Another Object. Click on the destination table in the left pane, then right-click in the middle pane and select Add Columns From Another Object. The columns will be added to the destination ..."},"682":{y:0,u:"../Content/User Guide/Database Functions/Database Functions.htm",l:-1,t:"Database Functions",i:0.00105099891624636,a:"Using Database Function Sets Database function sets contain a list of functions and operators that can be used for building transformations. These function sets may be created, edited, deleted, imported and exported using the Database Functions options from the Tools menu.  Column Transformation ..."},"683":{y:0,u:"../Content/User Guide/Database Functions/Maintaining Database Function Sets.htm",l:-1,t:"Maintaining Database Function Sets",i:0.000737535493508448,a:"To maintain the database function sets, select Tools \u003e Database Functions \u003e Maintain Database Functions. The following screen is displayed. Select a database function set from the Function Set drop-down list. To create a database function set, refer to  Creating a New Database Function Set To copy a ..."},"684":{y:0,u:"../Content/User Guide/Database Functions/Creating a New Database Function Set.htm",l:-1,t:"Creating a New Database Function Set",i:0.000894267204877406,a:"Creating a New Database Function Set To create a new database function set, select Tools \u003e Database Functions \u003e Maintain Database Functions. Click the New button. Enter a Function Set Name and select a Database from the drop-down list and then click OK."},"685":{y:0,u:"../Content/User Guide/Database Functions/Copying a Database Function Set.htm",l:-1,t:"Copying a Database Function Set",i:0.000894267204877406,a:"To copy an existing database function set, select Tools \u003e Database Functions \u003e Maintain Database Functions. Select a Function Set from the drop-down list and then click the Copy button. Enter the new Function Set Name and select a Database from the drop-down list and then click OK.  "},"686":{y:0,u:"../Content/User Guide/Database Functions/Editing a Database Function Set.htm",l:-1,t:"Editing a Database Function Set",i:0.000894267204877406,a:"To edit a database function set, select Tools \u003e Database Functions \u003e Maintain Database Functions. Select a database function set from the Function Set drop-down list. A group of buttons used to maintain the list of functions in a function set is available on the right side of the screen. These ..."},"687":{y:0,u:"../Content/User Guide/Database Functions/Deleting a Database Function Set.htm",l:-1,t:"Deleting a Database Function Set\n        ",i:0.000894267204877406,a:"Deleting a Database Function Set\n         To delete a database function set, select Tools \u003e Database Functions \u003e Maintain Database Functions. Select a Function Set from the drop-down list and then click the Delete button. Click Yes to confirm. When all functions are deleted, the function set ceases ..."},"688":{y:0,u:"../Content/User Guide/Database Functions/Loading Database Function Sets.htm",l:-1,t:"Loading Database Function Sets",i:0.000737535493508448,a:"To load a database function set, select Tools \u003e Database Functions \u003e Load Database Functions. The following screen is displayed. Select the xml file to load the database functions. By default, RED expects the xml files to be in ProgramData\\WhereScape\\Work directory. The xml file is validated using ..."},"689":{y:0,u:"../Content/User Guide/Database Functions/Exporting Database Function Sets.htm",l:-1,t:"Exporting Database Function Sets",i:0.000737535493508448,a:"To export Database Function Sets, select Tools \u003e Database Functions \u003e Export Database Functions. Select the Function Set to export from the drop-down list and then click OK. By default, RED exports the xml file to the ProgramData\\WhereScape\\Work directory but this can be changed. Change the File ..."},"690":{y:0,u:"../Content/User Guide/Extended Properties/Extended Properties.htm",l:-1,t:"Extended Properties",i:0.00207272140209382,a:"WhereScape RED provides a facility for defining and managing extended database properties which can be used in a range of scenarios, one of the motives for their introduction was to aid interaction with the variety of new database technologies that RED customers want to exploit for their Business ..."},"691":{y:0,u:"../Content/User Guide/Extended Properties/Defining Extended Properties.htm",l:-1,t:"Defining Extended Properties",i:0.000737535493508448,a:"An extended property definition mainly consists of the following attributes: Variable - the name of the extended property in the format it is accessed from RED and included into scripts. Scope - the scope is a sub-set definition of an extended property variable which specifies the subset of database ..."},"692":{y:0,u:"../Content/User Guide/Extended Properties/Creating an Extended Property Definition.htm",l:-1,t:"Creating an Extended Property Definition",i:0.00255886908713425,a:"To create a new extended property definition, select Tools \u003e Extended Properties \u003e Maintain Extended Properties. On the Extended Properties Maintenance screen, click New. On the Extended Property Definition screen, enter the display and variable names and then configure the settings as described ..."},"693":{y:0,u:"../Content/User Guide/Extended Properties/Maintaining Extended Property Definitions.htm",l:-1,t:"Maintaining Extended Property Definitions",i:0.000737535493508448,a:"The Extended Properties Maintenance screen displays a list of existing extended property definitions and enables you to add a New extended property definition. Clicking an extended property definition from the list enables you to Copy, Edit or Delete the selected extended property.  In addition, you ..."},"694":{y:0,u:"../Content/User Guide/Extended Properties/Extended Properties Value Assignment.htm",l:-1,t:"Extended Properties Value Assignment",i:0.0016184788189205,a:"After defining the extended property, you can assign values to each of the variable available in the Extended Properties tab of in-scope objects.   One extended property can have several connections and objects in its scope and therefore can have several values and assignments—one per connection and ..."},"695":{y:0,u:"../Content/User Guide/Extended Properties/Setting Up Extended Property Values for a Connection.htm",l:-1,t:"Setting Up Extended Property Values for a Connection",i:0.000737535493508448,a:"Setting Up Extended Property Values for a Connection The extended property values for a connection are assigned and maintained in the Extended Properties tab of the connection Properties screen.  Connection Extended Properties   "},"696":{y:0,u:"../Content/User Guide/Extended Properties/Setting Up Extended Property Values for an Object.htm",l:-1,t:"Setting Up Extended Property Values for an Object",i:0.000737535493508448,a:"Setting Up Extended Property Values for an Object The extended property values for an object are assigned and maintained in the Extended Properties tab of the table Properties screen.  WhereScape RED Object Extended Properties   "},"697":{y:0,u:"../Content/User Guide/Extended Properties/Extended Properties Lookup.htm",l:-1,t:"Extended Properties Lookup",i:0.000737535493508448,a:"  Extended properties can be accessed in the following four ways:   1. All template driven code generation Template engine reference examples using pebble syntax:   table.extendedPropertyValuesByName[“\u003cpropertyName\u003e”] table.loadInfo.sourceConnection.extendedPropertyValuesByName[“\u003cpropertyName\u003e”] ..."},"698":{y:0,u:"../Content/User Guide/Extended Properties/Extended Properties Data Migration Between Repositories.htm",l:-1,t:"Extended Properties Data Migration Between Repositories",i:0.000737535493508448,a:"Once extended properties are defined and set, they can be propagated to the other RED repositories as follows: The definitions are exported from the source repository and imported to the target repository via the Tools \u003e Extended Properties menu. The values assigned to extended properties are ..."},"699":{y:0,u:"../Content/User Guide/Extended Properties/Exporting Extended Properties.htm",l:-1,t:"Exporting Extended Properties",i:0.000737535493508448,a:"To export extended properties from RED, select Tools \u003e Extended Properties \u003e Export Extended Properties. The following window is displayed. By default, RED exports the extended property (EXTPROP) file to Program Files\\WhereScape\\Work directory, but this can be changed. Type in the File name and then ..."},});