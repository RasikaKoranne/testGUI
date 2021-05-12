define({"700":{y:0,u:"../Content/User Guide/Extended Properties/Loading Extended Properties.htm",l:-1,t:"Loading Extended Properties",i:0.000737535493508448,a:"To load an extended property file, select Tools \u003e Extended Properties \u003e Load Extended Properties. The following window is displayed. Select the extended property (EXTPROP) file to load. By default, RED expects the extprop files to be in Program Files\\WhereScape\\Work directory, but this can be ..."},"701":{y:0,u:"../Content/User Guide/Multi Source Processing/Multi Source Processing.htm",l:-1,t:"Multi Source Processing",i:0.00180470088591922,a:"WhereScape RED enables you to process data from more than one source query into a single consolidated table. The multi-source processing capability is designed to provide users with flexibility in the definition of component source statements and the ability to independently process multi source ..."},"702":{y:0,u:"../Content/User Guide/Multi Source Processing/Multi Source Functions and Features.htm",l:-1,t:"Multi Source Functions and Features",i:0.000737535493508448,a:"Multi Source Functions and Features The following describes the WhereScape RED functions and features that are used to support multi source processing of data warehouse objects, created in RED."},"703":{y:0,u:"../Content/User Guide/Multi Source Processing/Source Mapping Object.htm",l:-1,t:"Source Mapping Object",i:0.000737535493508448,a:"Source Mapping objects are child objects that are used in WhereScape RED to map columns from one or more source tables to an existing target table in RED. A Source Mapping object is built from the Data Warehouse connection and can be created from one or more source tables.  Refer to  Adding Source ..."},"704":{y:0,u:"../Content/User Guide/Multi Source Processing/Source Mapping Tool.htm",l:-1,t:"Source Mapping Tool",i:0.000737535493508448,a:"A Source Mapping tool is available in WhereScape RED which enables you to graphically map columns from one or more source tables to an existing target table in RED. This tool provides a graphical representation of the mapped columns between the source tables and the target table. The columns from ..."},"705":{y:0,u:"../Content/User Guide/Multi Source Processing/Global Naming of Source Mappings.htm",l:-1,t:"Global Naming of Source Mappings",i:0.000737535493508448,a:"Global Naming of Source Mappings The Global Naming Conventions option includes the Global Naming of Source Mappings setting that enables you to define naming standards for the source mapping objects in RED. Refer to  Global Naming Conventions \u003e Global Naming of Source Mappings  for details.\n\n"},"706":{y:0,u:"../Content/User Guide/Multi Source Processing/Independent Execution of Update Procedures.htm",l:-1,t:"Independent Execution of Update Procedures",i:0.000737535493508448,a:"The update procedures associated with the target table and the source mapping objects can be executed individually, separate from each other. Similar to other table objects in RED, the update procedures can be executed on demand or via the  Scheduler . This provides the flexibility of scheduling the ..."},"707":{y:0,u:"../Content/User Guide/Multi Source Processing/Table Column Properties.htm",l:-1,t:"Table Column Properties",i:0.000737535493508448,a:"The Source Details table column properties is used to specify where to obtain the source data and provides options for processing (transformation and join settings) the source data. You can also define and manage column source mappings from this screen. Refer to the relevant table Column Properties ..."},"708":{y:0,u:"../Content/User Guide/Multi Source Processing/Adding Source Mapping to Objects.htm",l:-1,t:"Adding Source Mapping to Objects",i:0.00136446233898428,a:"When adding source columns to a table object in RED, the target table’s current source columns are used to create the first source mapping object and then proceeds to create the second source mapping object which contains the additional source columns that need to be mapped to the target table. The ..."},"709":{y:0,u:"../Content/User Guide/Multi Source Processing/Drag and Drop.htm",l:-1,t:"Drag and Drop",i:0.000737535493508448,a:"The common approach to create source mappings is to select the source table that contains the columns that you want to add and then drag this table into the target table.  This process creates two source mapping objects, the first one contains the original source mapping of the target table and ..."},"710":{y:0,u:"../Content/User Guide/Multi Source Processing/Maintaining Source Column Mappings.htm",l:-1,t:"Maintaining Source Column Mappings",i:0.00136446233898428,a:"The following describe the process for managing source mappings between the source table(s) and the target table.  Right click the Source Mapping object from the left-pane and then select Maintain Source Mappings from the context menu. Click the connection point of the source column you want to map ..."},"711":{y:0,u:"../Content/User Guide/Multi Source Processing/Update Procedures_SourceMappingObjects.htm",l:-1,t:"Generating Update Procedures for Source Mapping Objects",i:0.00338734238398519,a:"After successfully defining and creating the Source Mapping objects, you can generate the update procedure for each object via a template to populate the target table. Generating update and custom procedures for Source Mapping objects is completed using the same workflow as all objects in RED that ..."},"712":{y:0,u:"../Content/User Guide/Multi Source Processing/Executing Update Procedures via Scheduler.htm",l:-1,t:"Executing Update Procedures via Scheduler",i:0.000737535493508448,a:"The update procedures associated with the target table and the source mapping objects can be executed individually, separate from each other. Similar to other table objects in RED, the update procedures can be executed via the Scheduler.  Click the Scheduler tab to open the Scheduler window. Click ..."},"713":{y:0,u:"../Content/User Guide/Multi Source Processing/Reverting to Non Source Mapping Object.htm",l:-1,t:"Reverting to Non Source Mapping Object",i:0.000737535493508448,a:"You can revert the target table to a non-source mapping object if you delete its associated source mapping objects. If only a single source mapping object is left, right clicking the remaining source mapping object provides the option Revert to Non-Source Mapping Object.  "},"714":{y:0,u:"../Content/User Guide/Multi Source Processing/Listing Source Mapping Objects.htm",l:-1,t:"Listing Source Mapping Objects",i:0.00361690844247454,a:"You can view a list of source mapping objects that are defined in a  Project, Project Group or Object Group  in RED. This enables you to quickly view and manage source mapping objects that exist within your data warehouse. List Source Mapping Objects in a Project or Project Group: Right-click the ..."},"715":{y:0,u:"../Content/User Guide/Table and Column Comments/Table and Column Comments.htm",l:-1,t:"Table and Column Comments",i:0.00081886771114216,a:"WhereScape RED enables you to manage table and column comments outside your data warehouse environment and then load the updated comments back into the metadata repository; and subsequently copy them to the target database.  The comments can be exported from the metadata repository and imported ..."},"716":{y:0,u:"../Content/User Guide/Table and Column Comments/Defining Table Comments.htm",l:-1,t:"Defining Table Comments",i:0.000737535493508448,a:"Defining Table Comments Table Properties  The table comments are defined in the Description field of the table\u0027s Properties. The comments in this field, along with the Table Name and Business Display Name (EUL) fields are used when exporting/importing table comments.  "},"717":{y:0,u:"../Content/User Guide/Table and Column Comments/Exporting Table Comments.htm",l:-1,t:"Exporting Table Comments",i:0.000737535493508448,a:"To export table comments from RED, select Tools \u003e Table and Column Comments \u003e Export Table Comments. The Table Comments Export pop-up window is displayed:  Type in the directory and file name of the export file or click the folder icon to navigate to the required directory.  Select or de-select the ..."},"718":{y:0,u:"../Content/User Guide/Table and Column Comments/Loading Table Comments.htm",l:-1,t:"Loading Table Comments",i:0.000737535493508448,a:"To load/import table comments to RED from an external (.csv) file, select Tools \u003e Table and Column Comments \u003e Load Table Comments.    The Table Comments Import pop-up window is displayed: Type in the directory and file name of the source file or click the folder icon to navigate to the required ..."},"719":{y:0,u:"../Content/User Guide/Table and Column Comments/Defining Column Comments.htm",l:-1,t:"Defining Column Comments",i:0.000737535493508448,a:"Column Properties  The column comments are defined in the Column Description field of the column\u0027s Properties. The comments in this field, along with the Table Name, Column Name, and Column Title/Business Display Name fields are used when exporting/importing column comments.  "},"720":{y:0,u:"../Content/User Guide/Table and Column Comments/Exporting Column Comments.htm",l:-1,t:"Exporting Column Comments",i:0.000737535493508448,a:"To export table comments from RED, select Tools \u003e Table and Column Comments \u003e Export Column Comments. The Column Comments Export pop-up window is displayed:  Type in the directory and file name of the export file or click the folder icon to navigate to the required directory.  Select or de-select ..."},"721":{y:0,u:"../Content/User Guide/Table and Column Comments/Loading Column Comments.htm",l:-1,t:"Loading Column Comments",i:0.000737535493508448,a:"To load/import column comments to RED from an external (.csv) file, select Tools \u003e Table and Column Comments \u003e Load Column Comments. The Column Comments Import pop-up window is displayed:  Type in the directory and file name of the source file or click the folder icon to navigate to the required ..."},"722":{y:0,u:"../Content/User Guide/Table and Column Comments/Importing Comments from an External Source.htm",l:-1,t:"Importing Comments from an External Source",i:0.00157343795414289,a:"The import function supports Microsoft Excel 2013 comma separated value (.csv) file format for importing comments to RED. Table Comments Each row of data includes the Table Name, Business Display Name (EUL table objects only) and Table Comments (Description). Column Comments Each row of data ..."},"723":{y:0,u:"../Content/User Guide/Table and Column Comments/Viewing the Import Export.htm",l:-1,t:"Viewing the Import/Export Logs",i:0.00157343795414289,a:"RED creates a log to aid in troubleshooting, in case issues are encountered during the import/export process.  After completing the import/export process, you can click Open Log File or Open Log File Folder from the Table Comments Import/Export pop-up window to view the log file generated.  The ..."},"724":{y:0,u:"../Content/User Guide/UI Configurations/UI Configurations.htm",l:-1,t:"UI Configurations",i:0.00188348937143945,a:"UI Configurations allow the user to define the fields available on certain configurable UI’s. RED stores any data captured in these fields and treats it like any other object metadata, making it available to all automation aspects of the tool. Configurable UI’s Connection Properties Allows ..."},"725":{y:0,u:"../Content/User Guide/Host Script Languages/Host Script Languages.htm",l:-1,t:"Host Script Languages",i:0.00636673460238671,a:"WhereScape RED provides a facility for defining and managing host script languages to enable users to implement host scripts in their preferred scripting language, e.g. Python, Perl, PowerShell, etc. This provide RED users with the flexibility of using different types of script languages for the ..."},"726":{y:0,u:"../Content/User Guide/Host Script Languages/Defining Host Script Languages.htm",l:-1,t:"Defining Host Script Languages",i:0.000737535493508448,a:"Host Script Language definitions consist of the following : These user defined host script languages can be created and managed, using the Host Script Languages facility which is launched from the Tools menu. The following options are available: Maintain Host Script Languages is used to add new or ..."},"727":{y:0,u:"../Content/User Guide/Host Script Languages/Applying Host Script Languages.htm",l:-1,t:"Applying Host Script Languages",i:0.00136446233898428,a:"The defined Host Script Language types can be applied as a Template type or as the type of a Host Script object in RED. This is done via the Properties screen of the Template or Host Script object. Template Properties The Type field specifies what the template can be used for in RED. Refer to  ..."},"728":{y:0,u:"../Content/User Guide/Host Script Languages/Maintaining Host Script Languages.htm",l:-1,t:"Maintaining Host Script Languages",i:0.00344371381166654,a:"The Maintain Host Script Languages screen displays a list of host script language types configured in RED and enables you to add a New host script language type. Clicking a host script language type from the list enables you to Copy, Edit or Delete the selected language type. The following describe ..."},"729":{y:0,u:"../Content/User Guide/Host Script Languages/Adding a Host Script Language Type.htm",l:-1,t:"Adding a Host Script Language Type",i:0.0036650265111778,a:"To add a new host script language type, select Tools \u003e Host Script Languages \u003e Maintain Host Script Languages. On the Maintain Host Script Languages screen, click New. On the Edit Host Script Language screen, enter the properties of the host script language being added. Click OK to exit the Edit ..."},"730":{y:0,u:"../Content/User Guide/Host Script Languages/Host Script Lang Data Migrtn Bet Repos.htm",l:-1,t:"Host Script Languages Data Migration Between Repositories",i:0.000737535493508448,a:"Host Script Languages Data Migration Between Repositories Host script languages defined and set can be propagated to the other RED repositories. The definitions are exported from the source repository and imported to the target repository via the Tools \u003e Host Script Languages menu.  "},"731":{y:0,u:"../Content/User Guide/Host Script Languages/Loading Host Languages.htm",l:-1,t:"Loading Host Languages",i:0.000737535493508448,a:"To load host script language file, select Tools \u003e Host Script Languages \u003e Load Host Script Languages.   The following window is displayed. Select the host script language (HSCLANG) file to load . By default, RED expects the hsclang files to be in Program Files\\WhereScape\\Work directory, but this can ..."},"732":{y:0,u:"../Content/User Guide/Host Script Languages/Exporting Host Script Languages.htm",l:-1,t:"Exporting Host Script Languages",i:0.000737535493508448,a:"To export host script languages from RED, select Tools \u003e Host Script Languages \u003e Export Host Script Languages. The following window is displayed. By default, RED exports the host script language (HSCLANG) file to Program Files\\WhereScape\\Work directory, but this can be changed. Type in the File name ..."},"733":{y:0,u:"../Content/User Guide/Dedicated Command Line Interface.htm",l:-1,t:"Dedicated Command Line Interface",i:0.00129555473409146,a:"(REDCLI)   WhereScape RED provides a dedicated command line interface called REDCLI  which enables you to perform command functions. The REDCLI tool is available in the RED Windows installation directory. This tool can be called from 3rd party applications or Windows scripting languages to perform ..."},"734":{y:0,u:"../Content/User Guide/RED Command Line Arguments/RED Command Line.htm",l:-1,t:"RED Command Line Interface",i:0.000737535493508448,a:"RED Command Line Interface WhereScape RED provides command line interface applications that you can use to perform different tasks or execute functions and operations outside the RED GUI. RED Client Command Line RED Setup Administrator Command Line  "},"735":{y:0,u:"../Content/User Guide/RED Command Line Arguments/RED Client Command Line.htm",l:-1,t:"RED Client Command Line (med.exe)",i:0.00105099891624636,a:"The RED Client command line interface enables you to execute commands to:  Generate documentation in batch Create and deploy applications in batch Perform start up tasks for a new metadata\n                                    repository  The following is a sample Windows Command Prompt that displays ..."},"736":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Batch Documentation Creation.htm",l:-1,t:"Batch Documentation Creation",i:0.0010353297139627,a:"Batch Documentation Creation The following describe the relevant command line arguments for creating batch documentation (--create-docs or -BD):     "},"737":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Batch Deployment Application Creation.htm",l:-1,t:"Batch Deployment Application Creation",i:0.0010353297139627,a:"Batch Deployment Application Creation The following describe the relevant command line arguments for creating batch deployment application (--create-deploy-app or -BA):     "},"738":{y:0,u:"../Content/User Guide/RED Command Line Arguments/New MD Repo Startup.htm",l:-1,t:"New Metadata Repository Start up Task Creation",i:0.0010353297139627,a:"New Metadata Repository Start up Task Creation The following describe the relevant command line arguments for creating start up tasks for a new metadata repository (--new-meta-repo or -NEW):   "},"739":{y:0,u:"../Content/User Guide/RED Command Line Arguments/RED Setup Administrator Command Line.htm",l:-1,t:"RED Setup Administrator Command Line (adm.exe)",i:0.00105099891624636,a:"The RED Setup Administrator command line interface enables you to execute commands to : Quickly deploy a WhereScape RED application to create and populate a data warehouse Quickly create  a RED repository with the required metadata tables Quickly load a file that contains language data into RED ..."},"740":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Quick Application.htm",l:-1,t:"Quick Application",i:0.000865161587988842,a:"Quick Application The following describe the relevant command line arguments for quick application (--quick-app or -QA):     "},"741":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Quick Repository.htm",l:-1,t:"Quick Repository",i:0.000865161587988842,a:"Quick Repository The following describe the relevant command line arguments for quick repository (--quick-repo or -QR):     "},"742":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Quick Language.htm",l:-1,t:"Quick Language",i:0.000865161587988842,a:"Quick Language The following describe the relevant command line arguments for quick language (--quick-lang or -QL):       "},"743":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Quick Validate.htm",l:-1,t:"Quick Validate",i:0.000865161587988842,a:"Quick Validate The following describe the relevant command line arguments for quick validate (--quick-validate or -QV):     "},"744":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Quick Tutorial.htm",l:-1,t:"Quick Tutorial",i:0.000865161587988842,a:"Quick Tutorial The following describe the relevant command line arguments for quick tutorial (--quick-tutorial or -QT):       "},"745":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Windows Scheduler.htm",l:-1,t:"Windows Scheduler",i:0.000865161587988842,a:"Windows Scheduler The following describe the relevant command line arguments for Windows scheduler (--win-scheduler or -WS):     "},"746":{y:0,u:"../Content/User Guide/RED Command Line Arguments/Deploy Application.htm",l:-1,t:"Deploy Application",i:0.000865161587988842,a:"Deploy Application The following describe the relevant command line arguments for deploy application (--deploy-app or -AL):     "},"747":{y:0,u:"../Content/Teradata/Loading Data Teradata/Flat File Load - Source Screen Teradata.htm",l:-1,t:"Flat File Load - Source Screen",i:0.00119934127606258,a:"Flat File Load - Source Screen The fields for the Flat File Source Screen are described below.  "},"748":{y:0,u:"../Content/User Guide/Procedures and Scripts/Script Generation (Windows_DB2).htm",l:-1,t:"Script Generation (Windows/DB2)",i:0.000737535493508448,a:"A sample Windows script for DB2 is as follows. The key components of the script are described below: The script makes use of a number of environmental variables. These variables are acquired from both the table and connection properties. These variables are established in the environment by either ..."},"749":{y:0,u:"../Content/Metadata Validate/Current Repository Validation.htm",l:-1,t:"Current Repository Validation",i:0.000737535493508448,a:"Use this option if you want to validate a RED metadata repository that you  are  currently logged.  Log into RED and click the Validate menu to select the Validate Metadata Repository option.  Click the Current metadata repository option to proceed. The  Metadata Validate tool connects to the ..."},"750":{y:0,u:"../Content/Teradata/Default Settings/Target Location Teradata.htm",l:-1,t:"Target Location",i:0.000995775738210754,a:"Target Location options enable users who are placing objects across multiple databases to set default target locations for new tables.  Default table target locations can be set for the following objects:  Load Stage Dimension Kpi Fact Fact Aggregate Join Index Data Store EDW 3NF View  Hub Table ..."},"751":{y:0,u:"../Content/Metadata Validate/Validating the RED Metadata.htm",l:-1,t:"Validating the RED Metadata",i:0.000737535493508448,a:"Validating the RED Metadata The following sections describe the steps to validate the RED metadata repository and the other software components required to run RED.    "},"752":{y:0,u:"../Content/Metadata Validate/Connect to Repository Validation.htm",l:-1,t:"Connect to Repository Validation",i:0.000737535493508448,a:"Use this option if you want to validate a RED metadata repository that you  are not currently logged. The following steps describe how to connect to a RED metadata repository and perform validation.  Log into RED and click the Validate menu to select the Validate Metadata Repository option.  You can ..."},"753":{y:0,u:"../Content/User Guide/Table Properties/Table Storage Screen DB2.htm",l:-1,t:"Table Storage Screen - DB2",i:0.000911415859120201,a:"Table Storage Screen - DB2 Typical Storage screen for a DB2 table: Location Storage Other"},"754":{y:0,u:"../Content/Metadata Validate/Metadata Upgrade Required.htm",l:-1,t:"Metadata Upgrade Required",i:0.00136446233898428,a:"Upgrade of the metadata is required if the Metadata Validate tool identifies changes in the metadata version or table objects in the metadata repository. Each type of upgrade is described below. Metadata version upgrade If the  Metadata Validate tool determines that the metadata version is not the ..."},"755":{y:0,u:"../Content/Setup Wizard/Custom Installation New Repo.htm",l:-1,t:"Custom Installation - New Repository",i:0.00105099891624636,a:"Selecting the Create new repository option displays the Configure Metadata Database screen that enables you to specify a data source to which RED connects and the log in details for the selected source database.  Type in the required metadata connection details:    Click Validate to continue the ..."},"756":{y:0,u:"../Content/User Guide/Fact Tables/Creating a Partnd Fact Table DB2.htm",l:-1,t:"Creating a Partitioned Fact Table in DB2",i:0.000737535493508448,a:"In WhereScape RED a partitioned fact table can only be created from an existing fact table. The process therefore is to create a fact table normally, including the update procedure and indexes.  The table is then partitioned through the Storage screen of the fact table\u0027s properties dialog. ..."},"757":{y:0,u:"../Content/License Management/RED License Management Overview.htm",l:-1,t:"RED License Management Overview",i:0.000737535493508448,a:"WhereScape RED provides a license management tool that enables you to install a new license and validate or maintain existing RED licenses. This tool is launched from the Help menu: The stand alone application (RedInstallLicense.exe) can also be run from the RED Windows Installation directory. This ..."},"758":{y:0,u:"../Content/Teradata/Loading Data Teradata/Loading Data from Flat Files using SSIS Teradata.htm",l:-1,t:"Loading Data from Flat Files using SSIS",i:0.00105099891624636,a:"Flat files can be loaded into RED from a Windows Connection using SQL Server Integration Services (SSIS). The instructions below detail how to add the SSIS connection string to the data warehouse connection and load flat files using the drag and drop functionality to create Load tables. To load ..."},"759":{y:0,u:"../Content/User Guide/Table Properties/Statistics Screen.htm",l:-1,t:"Statistics Screen",i:0.000737535493508448,a:"Statistics Screen This screen shows the default values; but if these fields are left blank, then the default values will be used."},"760":{y:0,u:"../Content/Teradata/Connections/Database Datawarehouse Metadata Teradata.htm",l:-1,t:"Database - Data Warehouse/ Metadata Repository",i:0.000995775738210754,a:"This topic describes the details of the connection Properties as they apply to Database type connections and specifically of the Data Warehouse or Metadata repository connection. The Data Warehouse connection is the connection that stores the metadata repository and it is the connection that is used ..."},"761":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/Anlys Serv OLAP Cubes_Tblr Mdls.htm",l:-1,t:"Analysis Services OLAP Cubes/Tabular Models",i:0.000737535493508448,a:"Analysis Services OLAP Cubes/Tabular Models"},"762":{y:0,u:"../Content/Teradata/Loading Data Teradata/Loading Data into RED Load Tables using SSIS Teradata.htm",l:-1,t:"Loading Data into RED Load Tables using SSIS",i:0.000737535493508448,a:"To use SSIS loading, ensure that SSIS loads are enabled and that the SSIS version is set correctly in Tools\u003eOptions\u003eCode Generation\u003eGeneral. If you are loading from a Flat File source, refer to  Loading Data from Flat Files using SSIS . RED can extract and load data using SSIS from database tables ..."},"763":{y:0,u:"../Content/Application Deployment/Listing Deployed Applications.htm",l:-1,t:"Listing Deployed Applications",i:0.000737535493508448,a:"The following describe the steps for listing deployed applications in a RED repository.  Log into RED and click the Tools menu to select the Deployment Applications \u003e List Deployed Applications option. The Deployed Applications pane is displayed below the RED Builder window which lists all the ..."},"764":{y:0,u:"../Content/License Management/Installing a License.htm",l:-1,t:"Installing a License",i:0.000737535493508448,a:"The following describe the steps for installing your WhereScape RED license: Log into RED and click the Help menu to select the Show/Install License option.  You can also open the RED Windows installation directory and then double-click the RedInstallLicense.exe application to launch the license ..."},"765":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/Inspctng_Mod Adv Cube_prop.htm",l:-1,t:"OLAP Inspecting and Modifying Advanced Cube Properties",i:0.000737535493508448,a:"OLAP Inspecting and Modifying Advanced Cube Properties After the basic OLAP Cube has been defined, various properties of the OLAP Cube can be inspected or modified:  "},"766":{y:0,u:"../Content/User Guide/Not Supported Feature.htm",l:-1,t:"Not Supported Feature",i:0.000737535493508448,a:"Not Supported This feature is no longer supported in WhereScape RED, Help not available.  "},"767":{y:0,u:"../Content/Application Deployment/Creating a New Application.htm",l:-1,t:"Creating a New Application",i:0.000737535493508448,a:"The following describe the steps for creating a deployment application in RED.  Log into RED and click the Tools menu to select the Deployment Applications \u003e Create New Deployment Application option. The Build Deployment Application window is displayed which enables you to specify the application ..."},"768":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/Def Tblr Mdl.htm",l:-1,t:"Defining a Tabular Model",i:0.000737535493508448,a:"Browse your Datawarehouse connection. Within your Tabular Project, click on the Fact Table object group on the left pane to set your work pane to be your Fact Tables. Then from the right pane, drag a Fact Table into the middle pane, rename it with a tabular or relevant reference and select the ..."},"769":{y:0,u:"../Content/User Guide/Callable Routines/WsParameterRead_DB2.htm",l:-1,t:"DB2",i:0.000737535493508448,a:"DB2 DB2 Parameters: WsParameterRead Callable Routine Type: PROCEDURE. DB2 Examples: WsParameterRead"},"770":{y:0,u:"../Content/Installation Guide/XML Files for Application Loads.htm",l:-1,t:"XML Files for Application Loads",i:0.00218313211347897,a:"XML Options File for Application Loads If applications are being loaded using the command line, the saved application load options in the local registry can be outputted to an XML Options File for use in the application load. Refer to  Creating and Loading Applications from the Command Line  for ..."},"771":{y:0,u:"../Content/User Guide/Windows_Panes/Stage Tables.htm",l:-1,t:"Stage Tables",i:0.000737535493508448,a:"Stage Tables Following is an example of a standard menu for Stage tables.     "},"772":{y:0,u:"../Content/Setup Wizard/Installing the RED Metadata.htm",l:-1,t:"Installing the RED Metadata",i:0.000737535493508448,a:"Installing the RED Metadata The following sections describe the steps to install and configure the RED metadata repository and the other software components required to run RED.    "},});