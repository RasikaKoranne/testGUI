define({"235":{y:0,u:"../Content/User Guide/Data Vaults/Data Vault Settings.htm",l:-1,t:"Data Vault Settings",i:0.00239097915831904,a:"Settings for Data Vault objects can be configured from the Tools \u003e Options screen. Object Types Settings The Default Sub Type for Stage Table Objects drop-down includes the Data Vault Stage option.   Configure this setting, if you want to set Data Vault Stage to be the default Table Type in the ..."},"236":{y:0,u:"../Content/User Guide/Data Vaults/Table Column Properties.htm",l:-1,t:"Table Column Properties",i:0.000737535493508448,a:"The Key Type field drop-down include options for Data Vault hash keys, e.g. Change Hash Key (c), Hub Hash Key (h) and Link Hash Key (l). Hash Key source information are also displayed for these key types. Hash Key Sources – displays the source columns that are used to generate the selected Hub, Link ..."},"237":{y:0,u:"../Content/User Guide/Data Vaults/Maintain Hash Key Columns.htm",l:-1,t:"Maintain Hash Key Columns",i:0.000737535493508448,a:"The context menu for Stage Table objects, listed in the left pane provides an option for maintaining Data Vault hash key columns.  You can review the composition of existing hash keys for a Data Vault Stage table (Hub, Link and Satellite) and create additional hash keys by selecting the Maintain DV ..."},"238":{y:0,u:"../Content/User Guide/Data Vaults/Building Data Vault Objects.htm",l:-1,t:"Building Data Vault Objects",i:0.000737535493508448,a:"To build Data Vault objects (Hub, Link and Satellite) in WhereScape RED, involves the following procedures. Creating Load Tables with the required DSS columns. Creating Data Vault Stage tables. Generating update procedures for the Stage table via templates. Creating the Hub, Link and Satellite ..."},"239":{y:0,u:"../Content/User Guide/Data Vaults/Creating Load Tables.htm",l:-1,t:"Creating Load Tables",i:0.000737535493508448,a:"The following describe the steps for creating a Load table: Browse to the source system connection required (Browse \u003e Source Tables). Double-click the Load Table object group in the left pane, the middle pane displays a list of existing Load tables.   Click the source table from the right pane and ..."},"240":{y:0,u:"../Content/User Guide/Data Vaults/Creating Data Vault Stage.htm",l:-1,t:"Creating Data Vault Stage Tables",i:0.00830761159043195,a:"The following describe the steps for creating a Data Vault Stage table:  Browse to the Data Warehouse (click Browse \u003e Data Warehouse) connection to create the Data Vault Stage table. Double-click the Stage object group in the left pane, the middle pane displays a list of existing Stage tables.   ..."},"241":{y:0,u:"../Content/User Guide/Data Vaults/Generating Update Procedures for the Data Vault Stage Table.htm",l:-1,t:"Generating Update Procedures for the Data Vault Stage Table",i:0.00281653190487803,a:"After successfully defining and creating the Data Vault Stage table, you can generate the update procedure via a template to populate the table.   Click the Rebuild button in the table Properties screen to launch the procedure generation Wizard to populate the table. On the Processing tab of Table ..."},"242":{y:0,u:"../Content/User Guide/Data Vaults/Creating the Hub, Link and Satellite Tables.htm",l:-1,t:"Creating the Hub, Link and Satellite Tables",i:0.00324524287541177,a:"After successfully creating and populating the Data Vault Stage table, you can now create the Hub, Link and Satellite tables. The Hub, Link and Change hash keys information stored in the Data Vault Stage table is used by the Wizard for building these Data Vault objects.   Creating the Hub table The ..."},"243":{y:0,u:"../Content/User Guide/Data Vaults/Generating Update Procedures for Hub, Link and Satellite Tables.htm",l:-1,t:"Generating Update Procedures for Hub, Link and Satellite Tables",i:0.00798743337784737,a:"The following describe the steps for generating update procedures via a template. Hub table  After successfully defining and creating the Hub table, you can generate the update procedure via a template to populate the table.   Click the Rebuild button in the table Properties screen to launch the ..."},"244":{y:0,u:"../Content/User Guide/Data Vaults/Changing the Data Vault Hash.htm",l:-1,t:"Changing the Data Vault Hash Key Function in WhereScape RED 6.9.1.0 and above",i:0.00592108018119416,a:"WhereScape RED ships templates (refer to  Data Vault Templates ) to generate the procedures for Data Vault objects, if the customer’s license includes Data Vault object support for  SQL Server, Oracle or Teradata database platforms.  Included in the Data Vault utility (wsl_\u003cdatabase\u003e_utility_dv) ..."},"245":{y:0,u:"../Content/User Guide/Custom Objects.htm",l:-1,t:"Custom Objects",i:0.000737535493508448,a:"Custom1 and Custom2 objects are user defined objects. These Object types can be renamed in the Tools \u003e Options \u003e Object Types \u003e Object Names menu. A Custom object license is required for these object types. Custom objects have the same options and properties as EDW 3NF tables. Refer to  EDW 3NF ..."},"246":{y:0,u:"../Content/User Guide/Fact Tables/Fact Tables.htm",l:-1,t:"Fact Tables",i:0.000737535493508448,a:"A Fact table is normally defined, for our purposes, as a table with facts (measures) and dimensional keys that allow the linking of multiple dimensions. It is normally illustrated in the form of a Star Schema with the central Fact table and the outlying dimensions. The ultimate goal of the Fact ..."},"247":{y:0,u:"../Content/User Guide/Fact Tables/Detail Fact Tables.htm",l:-1,t:"Detail Fact Tables",i:0.000842023301087753,a:"A Detail Fact table is normally a transactional table that represents the business data at its lowest level of granularity. In many ways, these tables reflect the business processes within the organization.  These Fact tables are usually large and are focused on a specified analysis area.   There ..."},"248":{y:0,u:"../Content/User Guide/Fact Tables/Creating Detail Fact Tables.htm",l:-1,t:"Creating Detail Fact Tables",i:0.000737535493508448,a:"A Detail Fact table is typically created by dragging a staging table onto a fact table list. Once released, the dialog to create the fact table will commence. When a staging table is dragged into the drop target pane (middle pane), all Fact tables are by default Detail Fact tables.  If manually ..."},"249":{y:0,u:"../Content/User Guide/Fact Tables/Gen the Det Fact Upd Proc.htm",l:-1,t:"Generating the Detail Fact Update Procedure",i:0.000946511108667058,a:"Once a detail fact table has been defined in the metadata and created in the database, an update procedure can be generated to handle the update of the fact table. Generating a Procedure To generate a procedure, right-click on the fact table in the left pane and select Properties.  Click on the ..."},"250":{y:0,u:"../Content/User Guide/Fact Tables/Rollup or Combined Fact Tables.htm",l:-1,t:"Rollup or Combined Fact Tables",i:0.000842023301087753,a:"Rollup fact tables are typically the most heavily used fact tables in a data warehouse implementation. They provide a smaller set of information at a higher level of granularity.  These fact tables typically have a monthly granularity in the time dimension and reflect figures for the month or ..."},"251":{y:0,u:"../Content/User Guide/Fact Tables/Creating Rollup Fact Tables.htm",l:-1,t:"Creating Rollup Fact Tables",i:0.000737535493508448,a:"A rollup or combined Fact table is typically created by dragging a Fact table onto a Fact table list. In the example below, a double-click on the Fact table object group under the Sales project produced a list in the middle pane, showing the existing Fact tables.  A fact_sales_analysis rollup Fact ..."},"252":{y:0,u:"../Content/User Guide/Fact Tables/Gen the Rollup Fact Upd Proc.htm",l:-1,t:"Generating the Rollup Fact Update Procedure",i:0.000946511108667058,a:"Once a rollup fact table has been defined in the metadata and created in the database, an update procedure can be generated to handle the update of the fact table. Note: You can also generate an update procedure via a template, refer to  Rebuilding Update Procedures  for details. Generating a ..."},"253":{y:0,u:"../Content/User Guide/Fact Tables/KPI Fact Tables.htm",l:-1,t:"KPI Fact Tables",i:0.000842023301087753,a:"Key Performance Indicator (KPI) fact tables share a lot of similarities with the rollup fact tables in that they are typically at a monthly level of granularity and they combine information from multiple detail fact tables. They differ in that they provide specific sets of pre-defined information ..."},"254":{y:0,u:"../Content/User Guide/Fact Tables/Creating the KPI Dimension.htm",l:-1,t:"Creating the KPI Dimension",i:0.000737535493508448,a:"The KPI dimension essentially provides a record of each KPI or statistic we are tracking. There should be one row in this table for each such element.  The KPI fact table requires that this dimension contain at the least an artificial dimension key and a business key. We will refer to the business ..."},"255":{y:0,u:"../Content/User Guide/Fact Tables/Creating KPI Fact Tables.htm",l:-1,t:"Creating KPI Fact Tables",i:0.000737535493508448,a:"A KPI fact table is normally created manually.   Right-click the Fact Table object group in the left pane and select New Object. A dialog displays as shown below. Adding columns Once created, the KPI fact table need to have columns added. New columns can be added by dragging columns from the browser ..."},"256":{y:0,u:"../Content/User Guide/Fact Tables/Setup of KPI Fact Tables.htm",l:-1,t:"Setup of KPI Fact Tables",i:0.000737535493508448,a:"The set-up of a KPI fact table is somewhat more complex than the other types of fact table. Once all columns have been defined, the following steps need to be taken: Create and populate a KPI dimension that provides at least an id (unique identifier) for each KPI and a description. The key from this ..."},"257":{y:0,u:"../Content/User Guide/Fact Tables/KPI Setup.htm",l:-1,t:"KPI Setup",i:0.000737535493508448,a:"KPI Dimension The KPI dimension provides a means of selecting a specific KPI. This dimension needs to be built in advance of the KPI fact table. It does not need to be populated, as the KPI fact table will add entries to this table as required. A key and some form of unique identifier for the KPI is ..."},"258":{y:0,u:"../Content/User Guide/Fact Tables/Gen the KPI Fact Upd Proc.htm",l:-1,t:"Generating the KPI Fact Update Procedure",i:0.000737535493508448,a:"Once a Detail Fact table has been defined in the metadata and created in the database, an update procedure can be generated to handle the update of the Fact table. Generating a Procedure To generate a procedure, right-click the Fact table in the left pane and select Properties.  Click the Rebuild ..."},"259":{y:0,u:"../Content/User Guide/Fact Tables/Snapshot Fact Tables.htm",l:-1,t:"Snapshot Fact Tables",i:0.000842023301087753,a:"Snapshot fact tables provide an ‘as at’ view of some part of the business. They always have a time dimension that represents the ‘as at’ date. For example, we may have a weekly or monthly snapshot of our inventory information. Such a snapshot would allow us to see what inventory we had at a ..."},"260":{y:0,u:"../Content/User Guide/Fact Tables/Creating Snapshot Fact Tables.htm",l:-1,t:"Creating Snapshot Fact Tables",i:0.000737535493508448,a:"The creation of snapshot fact tables is very dependent on the method used to create the snapshot. In some cases they may be created in exactly the same way as detail fact tables.  These cases are typically where the OLTP application provides the ‘as at’ state. For example, an inventory system may ..."},"261":{y:0,u:"../Content/User Guide/Fact Tables/Gen the Snapshot Fact Upd Proc.htm",l:-1,t:"Generating the Snapshot Fact Update Procedure",i:0.000737535493508448,a:"Once a snapshot Fact table has been defined in the metadata and created in the database, an update procedure can be generated to handle the update of the Fact table. Generating a Procedure To generate a procedure, right-click the Fact table in the left pane and select Properties.  Click the Rebuild ..."},"262":{y:0,u:"../Content/User Guide/Fact Tables/Slowly Changing Fact Tables.htm",l:-1,t:"Slowly Changing Fact Tables",i:0.000842023301087753,a:"Slowly changing fact tables provide a complete history of changes for some part of the business. Typically, such fact tables are used for situations where a relatively small number of changes occur over time, but we need to track all of these changes.  A good example is an inventory stock holding ..."},"263":{y:0,u:"../Content/User Guide/Fact Tables/Creating Slwly Chgng Fact Tbls.htm",l:-1,t:"Creating Slowly Changing Fact Tables",i:0.000737535493508448,a:"WhereScape RED does not provide any automated way for creating a slowly changing fact table. The best method is to proceed as follows. Drag and drop the Stage table into a dimension target and create a dummy slowly changing dimension with the name we will be using for our fact table. (i.e. ..."},"264":{y:0,u:"../Content/User Guide/Fact Tables/Partitioned Fact Tables.htm",l:-1,t:"Partitioned Fact Tables",i:0.000842023301087753,a:"Partitioned Fact Tables Partitioned fact tables are normally used for performance reasons. They enables you to break a large fact table into a number of smaller tables (partitions).   WhereScape RED supports partitioned fact tables. The following section explains their creation and support."},"265":{y:0,u:"../Content/User Guide/Fact Tables/Creating a Partnd Fact Table SQL Srvr.htm",l:-1,t:"Creating a Partitioned Fact Table in SQL Server",i:0.000737535493508448,a:"In WhereScape RED, a partitioned fact table can only be created from an existing fact table. The process therefore is to create a fact table normally, including the update procedure and indexes.  The table is then partitioned through the Storage screen of the fact table\u0027s Properties window. ..."},"266":{y:0,u:"../Content/User Guide/Fact Tables/Creating a Partnd Fact Table Oracle.htm",l:-1,t:"Creating a Partitioned Fact Table in Oracle",i:0.000737535493508448,a:"In WhereScape RED a partitioned fact table can only be created from an existing fact table. The process therefore is to create a fact table normally, including the update procedure and indexes.  The table is then partitioned through the Storage screen of the fact table\u0027s properties dialog. ..."},"267":{y:0,u:"../Content/User Guide/Fact Tables/Gen the Partnd Fact Upd Proc.htm",l:-1,t:"Generating the Partitioned Fact Update Procedure",i:0.000737535493508448,a:"Once a partitioned fact table has been defined in the metadata and created in the database, an update procedure can be generated to handle the update of the fact table. Generating a Procedure To generate a procedure, right-click on the fact table in the left pane and select Properties.  Click on the ..."},"268":{y:0,u:"../Content/User Guide/Fact Tables/Fact Table Column Properties.htm",l:-1,t:"Fact Table Column Properties",i:0.000862920862603614,a:"Each fact table column has a set of associated properties. The definition of each property is defined below: If the Column name or Data type is changed for a column then the metadata will differ from the table as recorded in the database.  Use the Validate \u003e Validate Table Create Status menu option ..."},"269":{y:0,u:"../Content/User Guide/Fact Tables/Fact Table Col Transforms.htm",l:-1,t:"Fact Table Column Transformations",i:0.00147104466533905,a:"Each fact table column can have a transformation associated with it. The transformation is included in the generated procedure and executed as part of the procedure update.  The transformation must therefore be a valid SQL construct that can be included in a SELECT statement.  For example, we could ..."},"270":{y:0,u:"../Content/User Guide/Fact Tables/Fact Table Language Mapping.htm",l:-1,t:"Fact Table Language Mapping",i:0.000737535493508448,a:"The Fact table Properties screen has a tab called Language Mapping. Select the language from the drop-down list and then enter the translations for the Business Display Name and the Description in the chosen language.  The translations for these fields can then be pushed through into OLAP cubes."},"271":{y:0,u:"../Content/User Guide/Aggregation/Aggregation.htm",l:-1,t:"Aggregation",i:0.000737535493508448,a:"Two types of aggregate tables are discussed.   The first is where all non-additive facts and one or more dimensions are removed from a fact table. Typically this results in a smaller table that can answer a subset of the queries that could be posed against the fact table. This aggregate table still ..."},"272":{y:0,u:"../Content/User Guide/Aggregation/Creating an Aggregate Table.htm",l:-1,t:"Creating an Aggregate Table",i:0.000737535493508448,a:"In the left pane double-click on the aggregate group to list the aggregates in the middle pane and set aggregates as the drop target. From the Data Warehouse browse (right) pane drag a fact table into the middle pane and enter the aggregate name. Click ADD. The aggregate properties are displayed. ..."},"273":{y:0,u:"../Content/User Guide/Aggregation/Chng_Aggrgts Def Lk Bck Days.htm",l:-1,t:"Change an Aggregates Default Look Back Days",i:0.000737535493508448,a:"Change an Aggregate\u0027s Default Look Back Days WhereScape RED generate update procedures for aggregates that are incremental. Incremental updates are based on a date dimension key and number of look back days. The aggregate update process looks at any records that have been updated in the fact table ..."},"274":{y:0,u:"../Content/User Guide/Aggregation/Crtng an Aggrgt Sum Table.htm",l:-1,t:"Creating an Aggregate Summary Table",i:0.000737535493508448,a:"The creation of a summary table proceeds initially in the same way as an aggregate table. In the left pane double-click the Aggregate group to list the aggregates in the middle pane and set aggregates as the drop target. From the Data Warehouse browse (right) pane drag a fact table into the middle ..."},"275":{y:0,u:"../Content/User Guide/Aggregation/Aggregate Tbl Col Props.htm",l:-1,t:"Aggregate Table Column Properties",i:0.000737535493508448,a:"Each aggregate table column has a set of associated properties. The definition of each property is defined below: If the Column name or Data type is changed for a column, then the metadata will differ from the table as recorded in the database. Use the Validate \u003e Validate Table Create Status menu ..."},"276":{y:0,u:"../Content/User Guide/Aggregation/Aggregate Tbl Col Transforms.htm",l:-1,t:"Aggregate Table Column Transformations",i:0.00136446233898428,a:"Each aggregate table column can have a transformation associated with it. The transformation will be included in the generated procedure and will be executed as part of the procedure update. The transformation must therefore be a valid SQL construct that can be included in a Select statement. For ..."},"277":{y:0,u:"../Content/User Guide/Views/Views.htm",l:-1,t:"Views",i:0.000737535493508448,a:"Views are normally created from Dimensions. These Views are then used to define Dimensions in a Fact table where the Dimension appears multiple times. A classic example is the date dimension.  To facilitate the creation of the Fact table we create two dimension views to allow the date dimension to ..."},"278":{y:0,u:"../Content/User Guide/Views/Creating a Dimension View.htm",l:-1,t:"Dimension Views",i:0.00077236476270155,a:"A Dimension view is a database view of a Dimension table. It may be a full or partial view. It is typically used in cases such as date dimensions, where multiple date dimensions exist for one Fact table. In many data warehouses Dimension views are built as part of the end user layer but creating ..."},"279":{y:0,u:"../Content/User Guide/Views/View Column Re mapping.htm",l:-1,t:"View Column Re-mapping",i:0.000737535493508448,a:"The View Column Definition window is used for the automated re-mapping of certain column names. It provides an easy method for changing the column names for a large number of columns, when creating a View.  The various actions undertaken as a result of entries in this window can all be done or ..."},"280":{y:0,u:"../Content/User Guide/Views/Dimension View Language Mapping.htm",l:-1,t:"Dimension View Language Mapping",i:0.000737535493508448,a:"The Dimension View Properties screen has a Language Mapping tab. Select the language from the drop-down list and then enter the translations for the Business Display Name and the Description in the chosen language.  The translations for these fields can then be pushed through into OLAP cubes.  "},"281":{y:0,u:"../Content/User Guide/Views/Non Dimension Object Views.htm",l:-1,t:"Non-Dimension Object Views",i:0.000737535493508448,a:"WhereScape RED also supports creating views of objects other than dimensions (Load tables, Facts, Stage tables, Aggregates, etc.). A Fact View is a database view of a Fact table. It may be a full, partial view, or a view incorporating both the fact data and some dimensional attributes.  It is ..."},"282":{y:0,u:"../Content/User Guide/Views/Creating a Custom View.htm",l:-1,t:"Creating a Custom View",i:0.000737535493508448,a:"A custom view can be created within WhereScape RED to handle views that are not strictly one to one such as where multiple tables are joined or where a complex condition is placed on the view. There are two options for custom views, the first where the columns are defined in WhereScape RED and the ..."},"283":{y:0,u:"../Content/User Guide/Views/View Aliases.htm",l:-1,t:"View Aliases",i:0.000737535493508448,a:"View Aliases A View Alias provides the ability to create security views on SQL Server in an alternate schema. The View Aliases tab enables you to define additional/replica views."},"284":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/AnalysisServices OLAPCubes_Tabular Models.htm",l:-1,t:"Analysis Services OLAP Cubes/Tabular Models",i:0.000737535493508448,a:"Analysis Services OLAP Cubes/Tabular Models"},"285":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cubes.htm",l:-1,t:"OLAP Cubes",i:0.000737535493508448,a:"A cube is a set of related measures and dimensions that is used to analyze data. A measure is a transactional value or measurement that a user may want to aggregate. The source of measures are usually columns in one or more source tables. Measures are grouped into measure groups. A dimension is a ..."},"286":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/DefDatSrc for OLAP Cube.htm",l:-1,t:"Defining the Data Source for the OLAP Cube",i:0.00199138918446011,a:"Before we can create an OLAP cube, we first need to set up the data warehouse to be used as a source for Analysis Services cubes.  In the Data Warehouse Properties screen, the fields in the section When Connection is an OLAP Data Source are required.   Building the OLAP Connection String  The OLAP ..."},"287":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Defining an OLAP Cube.htm",l:-1,t:"OLAP Defining an OLAP Cube",i:0.000737535493508448,a:"OLAP Cubes can be created from fact, fact view or aggregate objects. A single cube can contain dates from multiple source star schemas, each defined with a measure group. An OLAP Cube consists of many parts namely, measure groups, measures, calculations, actions, dimensions, dimension hierarchies, ..."},"288":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/Inspecting_Modifying Advanced Cube_prop.htm",l:-1,t:"OLAP Inspecting and Modifying Advanced Cube Properties",i:0.000737535493508448,a:"OLAP Inspecting and Modifying Advanced Cube Properties After the basic OLAP Cube has been defined, various properties of the OLAP Cube can be inspected or modified:  "},"289":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/Creating_OLAPCube_Analysis Services Server.htm",l:-1,t:"OLAP Creating an OLAP Cube on the Analysis Services Server",i:0.000737535493508448,a:"If all the tasks above are completed ,then it is now possible to create the cube on the Analysis Services server. Right-click the OLAP Cube name and then select Create (Alter) Cube.  WhereScape RED checks that key components of the cube are correct, before it proceeds to issue the create command. ..."},"290":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Objects.htm",l:-1,t:"OLAP Cube Objects",i:0.000737535493508448,a:"OLAP Cube Objects"},"291":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Properties.htm",l:-1,t:"OLAP Cube Properties",i:0.000737535493508448,a:"The properties associated with a cube are described below. These properties relate both to the cube environment and to the cube itself.  There are seven tabs in the cube Properties screen. The first is the main properties, the second the processing and partitioning options and the rest are for ..."},"292":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Measure Groups.htm",l:-1,t:"OLAP Cube Measure Groups",i:0.000737535493508448,a:"A cube can contain multiple measure groups. In WhereScape RED each measure group can belong to a single cube, and each measure group relates to a single star schema. The Measure Groups Cube processing is defined in the tab entitled Measure Group Properties. The Measure Group Properties are shown by ..."},"293":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Msre Grp Proc_Prtns.htm",l:-1,t:"OLAP Cube Measure Group Processing/Partitions",i:0.000737535493508448,a:"Partitions define separately manageable data slices of the measure group data. Partitions can be created, processed and deleted independently within a Measure Group. Each Measure Group needs at least one partition to be defined to enable the Measure Group to be processed. Partitions are managed ..."},"294":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Msre Grp Prtns.htm",l:-1,t:"OLAP Cube Measure Group Partitions",i:0.000737535493508448,a:"OLAP Cube Measure Group Partitions The Measure Group Partition\u0027s properties are shown by right-clicking the Measure Group Partition displayed in the middle pane and then selecting Properties. The partition\u0027s properties associated with a measure group are described below."},"295":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Measures.htm",l:-1,t:"OLAP Cube Measures",i:0.000737535493508448,a:"Measures represent the numeric attributes of a fact table that are aggregated, using an OLAP aggregate function defined against each Measure. Each Measure is defined against a Measure Group, which is defined against a cube. The properties of a measure are shown by right-clicking a Measure and the ..."},"296":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Calculations.htm",l:-1,t:"OLAP Cube Calculations",i:0.000737535493508448,a:"Calculations provide the ability to define the derivation of a value at query time within a cube. The calculation is most typically a numeric derivation based on measures, but can be defined against any dimension. The calculation is defined in MDX (Multi-Dimensional eXpressions). The definition of a ..."},"297":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Key Perfor Indctrs.htm",l:-1,t:"OLAP Cube Key Performance Indicators",i:0.000737535493508448,a:"In Analysis Services, a KPI is a collection of calculations that are associated with a measure group in a cube that are used to evaluate business success. Typically, these calculations are a combination of Multidimensional Expressions (MDX) expressions or calculated members.  KPIs also have ..."},"298":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Actions.htm",l:-1,t:"OLAP Cube Actions",i:0.000737535493508448,a:"An action provides information to a client application to allow an action to occur based on the property of a clicked dimensional member. Actions can be of different types and they have to be created accordingly.  To view the definition of an Action, right-click the Action and select Properties. The ..."},"299":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Dimensions.htm",l:-1,t:"OLAP Cube Dimensions",i:0.00105099891624636,a:"OLAP Dimensions are associated automatically with a cube when a cube is created in WhereScape RED based on the underlying star schema. OLAP Dimensions that are associated with a cube can be displayed, or additional OLAP Dimensions can be manually added from the list of OLAP Dimensions defined in ..."},"300":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Cube Msr Grp Dims.htm",l:-1,t:"OLAP Cube Measure Group Dimensions",i:0.000737535493508448,a:"OLAP Cube Measure Group Dimensions Measure group dimensions are the relationships between cube Measure Groups and OLAP Dimensions. In WhereScape RED this equates to the relationships between Fact tables and Dimensions in the underlying star schema. The Properties are shown below:"},"301":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Dimension Objects.htm",l:-1,t:"OLAP Dimension Objects",i:0.000737535493508448,a:"OLAP Dimension Objects"},"302":{y:0,u:"../Content/User Guide/Analysis Services OLAP Cubes_Tabular Models/OLAP Dimension Overview.htm",l:-1,t:"OLAP Dimension Overview",i:0.000737535493508448,a:"OLAP Dimensions are dimensions that get created in an Analysis Services database. An OLAP Dimension is a collection of related attributes which can be used to provide information about fact data in one or more cubes. By default, attributes are visible as attribute hierarchies and can be used to ..."},});