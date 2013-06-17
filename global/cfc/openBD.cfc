<cfcomponent>

	<!--- Datasource Get config --->
	<cffunction name="getConfig" output="false" returntype="struct" hint="Returns a struct representation of the OpenBD server configuration (bluedragon.xml)">
		<cfset var admin = "" />
			<cflock scope="Server" type="readonly" timeout="5">
				<cfset admin = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").getConfig().getCFMLData() />
			</cflock>
		<cfreturn admin.server />
	</cffunction>
	

	<cffunction name="setDatasource" access="public" output="false" hint="Creates or updates a datasource">
		<cfargument name="name" type="string" required="true" hint="OpenBD Datasource Name" />
		<cfargument name="databasename" type="string" required="false" default="" hint="Database name on the database server" />
		<cfargument name="server" type="string" required="false" default="" hint="Database server host name or IP address" />
		<cfargument name="port"	type="numeric" required="false" default="0" hint="Port that is used to access the database server" />
		<cfargument name="username" type="string" required="false" default="" hint="Database username" />
		<cfargument name="password" type="string" required="false" default="" hint="Database password" />
		<cfargument name="hoststring" type="string" required="false" default="" hint="JDBC URL for 'other' database types. Databasename, server, and port arguments are ignored if a hoststring is provided." />
		<cfargument name="description" type="string" required="false" default="" hint="A description of this data source" />
		<cfargument name="initstring" type="string" required="false" default="" hint="Additional initialization settings" />
		<cfargument name="connectiontimeout" type="numeric" required="false" default="120" hint="Number of seconds OpenBD maintains an unused connection before it is destroyed" />
		<cfargument name="connectionretries" type="numeric" required="false" default="0" hint="Number of connection retry attempts to make" />
		<cfargument name="logintimeout" type="numeric" required="false" default="120" hint="Number of seconds before OpenBD times out the data source connection login attempt" />
		<cfargument name="maxconnections" type="numeric" required="false" default="3" hint="Maximum number of simultaneous database connections" />
		<cfargument name="perrequestconnections" type="boolean" required="false" default="false" hint="Indication of whether or not to pool connections" />
		<cfargument name="sqlselect" type="boolean" required="false" default="true" hint="Allow SQL SELECT statements from this datasource" />
		<cfargument name="sqlinsert" type="boolean" required="false" default="true" hint="Allow SQL INSERT statements from this datasource" />
		<cfargument name="sqlupdate" type="boolean" required="false" default="true" hint="Allow SQL UPDATE statements from this datasource" />
		<cfargument name="sqldelete" type="boolean" required="false" default="true" hint="Allow SQL DELETE statements from this datasource" />
		<cfargument name="sqlstoredprocedures" type="boolean" required="false" default="true" hint="Allow SQL stored procedure calls from this datasource" />
		<cfargument name="drivername" type="string" required="false" default="" hint="JDBC driver class to use" />
		<cfargument name="action" type="string" required="false" default="create" hint="Action to take on the datasource (create or update)" />
		<cfargument name="existingDatasourceName" type="string" required="false" default="" hint="The existing (old) datasource name so we know what to delete if this is an update" />
		<cfargument name="verificationQuery" type="string" required="false" default="" hint="Custom verification query for 'other' driver types" />
		
		<cfinvoke method="getConfig" returnvariable="localConfig" >
		</cfinvoke>
		
		<cfset var datasourceSettings = structNew() />
		<!--- make sure configuration structure exists, otherwise build it --->
		<cfif (NOT StructKeyExists(localConfig, "cfquery")) OR (NOT StructKeyExists(localConfig.cfquery, "datasource"))>
			<cfset localConfig.cfquery.datasource = ArrayNew(1) />
		</cfif>
		
		<!--- if the datasource already exists and this isn't an update, throw an error --->
		<cfif bddatasourceExists(arguments.name) EQ "false">
			<!--- build up the universal datasource settings --->
			<cfscript>
				// Set the params
				datasourceSettings.name = trim(lcase(arguments.name));
				datasourceSettings.displayname = arguments.name;
				datasourceSettings.databasename = trim(arguments.databasename);
				datasourceSettings.username = trim(arguments.username);
				datasourceSettings.password = trim(arguments.password);
				datasourceSettings.drivername = trim(arguments.drivername);
				datasourceSettings.initstring = trim(arguments.initstring);
				datasourceSettings.sqlselect = ToString(arguments.sqlselect);
				datasourceSettings.sqlinsert = ToString(arguments.sqlinsert);
				datasourceSettings.sqlupdate = ToString(arguments.sqlupdate);
				datasourceSettings.sqldelete = ToString(arguments.sqldelete);
				datasourceSettings.sqlstoredprocedures = ToString(arguments.sqlstoredprocedures);
				datasourceSettings.logintimeout = ToString(arguments.logintimeout);
				datasourceSettings.connectiontimeout = ToString(arguments.connectiontimeout);
				datasourceSettings.connectionretries = ToString(arguments.connectionretries);
				datasourceSettings.maxconnections = ToString(arguments.maxconnections);
				datasourceSettings.perrequestconnections = ToString(arguments.perrequestconnections);
				datasourceSettings.hoststring = ToString(arguments.hoststring);
				// prepend the new datasource to the localconfig array
				arrayPrepend(localConfig.cfquery.datasource, structCopy(datasourceSettings));
				// update the config
				setConfig(localConfig);
			</cfscript>
		</cfif>

		<cfreturn true />	
	</cffunction>


	<!--- Datasource Set config --->
	<cffunction name="setConfig" output="false"  >
		<cfargument name="currentConfig" type="struct" required="true" hint="The configuration struct, which is a struct representation of bluedragon.xml" />
			
			<cflock scope="Server" type="exclusive" timeout="5">
				<cfset admin.server = duplicate(arguments.currentConfig) />
				<cfset admin.server.openbdadminapi.lastupdated = DateFormat(now(), "dd/mmm/yyyy") & " " & TimeFormat(now(), "HH:mm:ss") />
				<cfset admin.server.openbdadminapi.version = "1.0" />
				<cfset xmlConfig = createObject("java", "com.naryx.tagfusion.xmlConfig.xmlCFML").init(admin) />
				<cfset success = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").writeXmlFile(xmlConfig) />
			</cflock>

		 	
	</cffunction>
</cfcomponent>