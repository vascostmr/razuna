<cfcomponent>
	
	<cffunction name="getConfig" output="false" returntype="struct" hint="Returns a struct representation of the OpenBD server configuration (bluedragon.xml)">
		<cfset var admin = structNew() />
			<cflock scope="Server" type="readonly" timeout="5">
				<cfadmin action="getDatasources" type="web" password="password" returnVariable="existingDatasources">
				<cfset arr = QueryToArray(existingDatasources)>
				<cfset admin.server.cfquery.datasource = arr>	
			</cflock>
		<cfreturn admin.server />
	</cffunction>
	
	<cffunction name="getDatasources" access="public" output="false" returntype="array" 
			hint="Returns an array containing all the data sources or a specified data source">
		<cfargument name="dsn" type="string" required="false" default="" hint="The name of the datasource to return" />
		
		<cfset var localConfig = getConfig() />
		<cfset var returnArray = "" />
		<cfset var dsnIndex = "" />
		<cfset var sortKeys = arrayNew(1) />
		<cfset var sortKey = structNew() />
		
		<!--- Make sure there are datasources --->
		<cfif NOT StructKeyExists(localConfig, "cfquery") OR NOT StructKeyExists(localConfig.cfquery, "datasource")>
			<cfthrow message="No registered datasources" type="bluedragon.adminapi.datasource" />
		</cfif>
		
		<!--- Return entire data source array, unless a data source name is specified --->
		<cfif NOT StructKeyExists(arguments, "dsn") or arguments.dsn is "">
			<!--- set the sorting information --->
			<cfset sortKey.keyName = "name" />
			<cfset sortKey.sortOrder = "ascending" />
			<cfset arrayAppend(sortKeys, sortKey) />
	
			<cfreturn variables.udfs.sortArrayOfObjects(localConfig.cfquery.datasource, sortKeys, false, false) />
		<cfelse>
			<cfset returnArray = ArrayNew(1) />
			<cfloop index="dsnIndex" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
				<cfif localConfig.cfquery.datasource[dsnIndex].name EQ arguments.dsn>
					<cfset returnArray[1] = Duplicate(localConfig.cfquery.datasource[dsnIndex]) />
					<cfreturn returnArray />
				</cfif>
			</cfloop>
			<cfreturn ArrayNew(1)>
		</cfif>
	</cffunction>
	
	<cffunction name="verifyDatasource" access="public" output="false" returntype="any" 
			hint="Verifies a datasource">
		<cfargument name="dsn" type="string" required="true" hint="Datasource name to verify" />
		
		<cfset var verified = false />
		<cfset var datasource = getDatasources(arguments.dsn).get(0) />
		<cfset var driverManager = createObject("java", "java.sql.DriverManager") />
		<cfset var dbcon = 0 />
		<cfset var stmt = 0 />
		<cfset var rs = 0 />
		
		<!--- check that we can hit the driver --->
		<cftry>
			<cfset registerDriver(datasource.drivername) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
		
		<!--- run a verification query based on the driver; need to do this in java so we get a clean connection, because 
				otherwise the connection from railo may be cached/pooled so changes to things like server name don't 
				get picked up --->
		<cfswitch expression="#datasource.drivername#">
			<!--- mysql and postgres --->
			<cfcase value="com.mysql.jdbc.Driver,org.postgresql.Driver">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT NOW()") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---<cfthrow message="Could not verify datasource: #CFCATCH.Message#"	type="bluedragon.adminapi.datasource" />--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- oracle --->
			<cfcase value="oracle.jdbc.OracleDriver">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT SYSDATE FROM DUAL") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---<cfthrow message="Could not verify datasource: #CFCATCH.Message#"	type="bluedragon.adminapi.datasource" />--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- sql server, h2 --->
			<cfcase value="com.microsoft.sqlserver.jdbc.SQLServerDriver,net.sourceforge.jtds.jdbc.Driver,org.h2.Driver" delimiters=",">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT 1") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---<cfthrow message="Could not verify datasource: #CFCATCH.Message#"	type="bluedragon.adminapi.datasource" />--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- odbc datasource --->
			<cfcase value="sun.jdbc.odbc.JdbcOdbcDriver">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT 1") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---<cfthrow message="Could not verify datasource: #CFCATCH.Message#"	type="bluedragon.adminapi.datasource" />--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- 'other' database types --->
			<cfdefaultcase>
				<!---try to use the custom verification query; otherwise throw an error --->
				<cfif structKeyExists(datasource, "verificationquery") and datasource.verificationquery is not "">
					<cftry>
						<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
						<cfset stmt = dbcon.createStatement() />
						<cfset rs = stmt.executeQuery(datasource.verificationquery) />
						
						<cfif rs.next()>
							<cfset verified = true />
						</cfif>
						<cfcatch type="any">
							<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
							<!---<cfthrow message="Could not verify datasource using driver #datasource.drivername#: #CFCATCH.Message#" type="bluedragon.adminapi.datasource" />--->
						</cfcatch>
					</cftry>
				<cfelse>
					<cfthrow message="Cannot verify custom JDBC driver datasources without a verification query. Please add a verification query to this datasource and try again." 
							type="bluedragon.adminapi.datasource" />
				</cfif>
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn verified />
	</cffunction>
	
	<!---<cffunction name="setDatasource" access="public" output="false" hint="Creates or updates a datasource">
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
		
		<cfadmin action="updateDatasource" type="web" password="password" classname="#arguments.drivername#"
			newname="#arguments.name#" name="#arguments.name#"
		   	dsn="#arguments.hoststring#"  database="#arguments.databasename#" dbusername="#arguments.username#" dbpassword="#arguments.password#"
		  
			connectionLimit="#arguments.maxconnections#"
		    connectionTimeout="#arguments.connectiontimeout#"
		    
		    allowed_select="#arguments.sqlselect#"
		    allowed_insert="#arguments.sqlinsert#"
		    allowed_update="#arguments.sqlupdate#"
		    allowed_delete="#arguments.sqldelete#"
				 
			allowed_alter="true"
		    allowed_drop="true"
		    allowed_revoke="true"
		    allowed_create="true"
		    >

		 <cfreturn true />		
	</cffunction>--->	
	
	<cffunction name="setDatasource" access="public" output="false" returntype="any" hint="Creates or updates a datasource">
		<cfargument name="name" type="string" required="true" hint="OpenBD Datasource Name" />
		<cfargument name="databasename" type="string" required="false" default="" hint="Database name on the database server" />
		<cfargument name="server" type="string" required="false" default="" hint="Database server host name or IP address" />
		<cfargument name="port"	type="numeric" required="false" default="0" hint="Port that is used to access the database server" />
		<cfargument name="username" type="string" required="false" default="" hint="Database username" />
		<cfargument name="password" type="string" required="false" default="" hint="Database password" />
		<cfargument name="hoststring" type="string" required="false" default="" 
				hint="JDBC URL for 'other' database types. Databasename, server, and port arguments are ignored if a hoststring is provided." />
		<cfargument name="filepath" type="string" required="false" default="" hint="File path for file-based databases (H2, etc.)" />
		<cfargument name="description" type="string" required="false" default="" hint="A description of this data source" />
		<cfargument name="connectstring" type="string" required="false" default="" hint="Additional connection information" />
		<cfargument name="initstring" type="string" required="false" default="" hint="Additional initialization settings" />
		<cfargument name="connectiontimeout" type="numeric" required="false" default="120" 
				hint="Number of seconds OpenBD maintains an unused connection before it is destroyed" />
		<cfargument name="connectionretries" type="numeric" required="false" default="0" hint="Number of connection retry attempts to make" />
		<cfargument name="logintimeout" type="numeric" required="false" default="120" 
				hint="Number of seconds before OpenBD times out the data source connection login attempt" />
		<cfargument name="maxconnections" type="numeric" required="false" default="3" hint="Maximum number of simultaneous database connections" />
		<cfargument name="perrequestconnections" type="boolean" required="false" default="false" 
				hint="Indication of whether or not to pool connections" />
		<cfargument name="sqlselect" type="boolean" required="false" default="true" hint="Allow SQL SELECT statements from this datasource" />
		<cfargument name="sqlinsert" type="boolean" required="false" default="true" hint="Allow SQL INSERT statements from this datasource" />
		<cfargument name="sqlupdate" type="boolean" required="false" default="true" hint="Allow SQL UPDATE statements from this datasource" />
		<cfargument name="sqldelete" type="boolean" required="false" default="true" hint="Allow SQL DELETE statements from this datasource" />
		<cfargument name="sqlstoredprocedures" type="boolean" required="false" default="true" hint="Allow SQL stored procedure calls from this datasource" />
		<cfargument name="drivername" type="string" required="false" default="" hint="JDBC driver class to use" />
		<cfargument name="action" type="string" required="false" default="create" hint="Action to take on the datasource (create or update)" />
		<cfargument name="existingDatasourceName" type="string" required="false" default="" 
				hint="The existing (old) datasource name so we know what to delete if this is an update" />
		<cfargument name="cacheResultSetMetadata" type="boolean" required="false" default="false" hint="MySQL specific setting" />
		<cfargument name="verificationQuery" type="string" required="false" default="" hint="Custom verification query for 'other' driver types" />
		<cfargument name="h2Mode" type="string" required="false" default="" hint="Compatibility mode for H2 database" />
		<cfargument name="h2IgnoreCase" type="boolean" required="false" default="true" hint="Boolean indicating whether or not H2 ignores case" />
		<cfset var localConfig = getConfig() />
		<cfset var defaultSettings = structNew() />
		<cfset var datasourceSettings = structNew() />
		<cfset var driver = 0 />
		<cfset var datasourceVerified = false />
		<!--- make sure configuration structure exists, otherwise build it --->
		<cfif (NOT StructKeyExists(localConfig, "cfquery")) OR (NOT StructKeyExists(localConfig.cfquery, "datasource"))>
			<cfset localConfig.cfquery.datasource = ArrayNew(1) />
		</cfif>
		
		<!--- if the datasource already exists and this isn't an update, throw an error --->
		<!---<cfif arguments.action is "create" and datasourceExists(arguments.name)>
			<cfthrow message="The datasource already exists" type="bluedragon.adminapi.datasource" />
		</cfif>--->
		
		<!--- if this is an update, delete the existing datasource --->
		<cfif arguments.action is "update">
			<cfset deleteDatasource(arguments.existingDatasourceName) />
			<cfset localConfig = getConfig() />
			
			<!--- if we're editing the only remaining datasource, need to recreate the datasource struture --->
			<cfif NOT StructKeyExists(localConfig, "cfquery") OR NOT StructKeyExists(localConfig.cfquery, "datasource")>
				<cfset localConfig.cfquery.datasource = ArrayNew(1) />
			</cfif>
		</cfif>
		
		<!---<cfif arguments.hoststring is "">
			<!--- if we don't have a port, use the defaults for the database type --->
			<cfif arguments.port eq 0>
				<cfset defaultSettings = getDriverInfo(arguments.drivername) />
				
				<cfif structKeyExists(defaultSettings, "port")>
					<cfset arguments.port = defaultSettings.port />
				</cfif>
			</cfif>
	
			<cfset datasourceSettings.hoststring = formatJDBCURL(trim(arguments.drivername), trim(arguments.server), 
																trim(arguments.port), trim(arguments.databasename), arguments.connectstring, 
																arguments.filepath, trim(arguments.username), trim(arguments.password), 
																arguments.cacheResultSetMetadata, arguments.h2Mode, arguments.h2IgnoreCase) />
		<cfelse>
			<cfset arguments.port = "" />
			<cfset datasourceSettings.hoststring = trim(arguments.hoststring) />
			
			<cfif trim(arguments.connectstring) is not "">
				<cfset datasourceSettings.hoststring = datasourceSettings.hoststring & trim(arguments.connectstring) />
			</cfif>
			
			<cfset datasourceSettings.verificationquery = trim(arguments.verificationQuery) />
		</cfif>--->
		
		<cfadmin action="updateDatasource" type="web" password="password" classname="#arguments.drivername#"
			newname="#arguments.name#" name="#arguments.name#"
		   	dsn="#arguments.hoststring#"  database="#arguments.databasename#" dbusername="#arguments.username#" dbpassword="#arguments.password#"
		  
			connectionLimit="#arguments.maxconnections#"
		    connectionTimeout="#arguments.connectiontimeout#"
		    
		    allowed_select="#arguments.sqlselect#"
		    allowed_insert="#arguments.sqlinsert#"
		    allowed_update="#arguments.sqlupdate#"
		    allowed_delete="#arguments.sqldelete#"
				 
			allowed_alter="true"
		    allowed_drop="true"
		    allowed_revoke="true"
		    allowed_create="true"
			
		    >
		 <cfreturn  true>	
	</cffunction>
	
	<cffunction name="QueryToArray" access="public" returntype="array" output="false" hint="This turns a query into an array of structures.">
    	<cfargument name="Data" type="query" required="yes" />

	    <cfscript>
		    var LOCAL = StructNew();
		
		    // Get the column names as an array.
		    LOCAL.Columns = ListToArray( ARGUMENTS.Data.ColumnList );
		
		    // Create an array that will hold the query equivalent.
		    LOCAL.QueryArray = ArrayNew( 1 );
		
		    // Loop over the query.
		    for (LOCAL.RowIndex = 1 ; LOCAL.RowIndex LTE ARGUMENTS.Data.RecordCount ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
			
			    // Create a row structure.
			    LOCAL.Row = StructNew();
			
			    // Loop over the columns in this row.
			    for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
			
				    // Get a reference to the query column.
				    LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
				
				    // Store the query cell value into the struct by key.
				    LOCAL.Row[ LOCAL.ColumnName ] = ARGUMENTS.Data[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
			
			    }
			
			    // Add the structure to the query array.
		    ArrayAppend( LOCAL.QueryArray, LOCAL.Row );
		
		    }
		
		    // Return the array equivalent.
		    return( LOCAL.QueryArray );
	
	    </cfscript>
    </cffunction>
    
    <cffunction name="createZipFile" access="public" output="true">
		<cfargument name="ZIPFILE" type="string" required="true" />
		<cfargument name="source" type="string" required="true" />
		<cfargument name="recurse" type="string" required="true" />
		<cfargument name="timeout" type="string" required="false" />

		<cfzip action="zip" file="#arguments.ZIPFILE#" source="#arguments.source#" recurse="#arguments.recurse#"  />
		
		<!--- Return --->
		<cfreturn true/>
	</cffunction>
	
	<cffunction name="extractZipFile" access="public" output="true">
		<cfargument name="ZIPFILE" type="string" required="true" />
		<cfargument name="destination" type="string" required="true" />
		<cfzip action="unzip" file="#arguments.ZIPFILE#" destination="#arguments.destination#" />
		<!--- Return --->
		<cfreturn true/>
	</cffunction>
</cfcomponent>