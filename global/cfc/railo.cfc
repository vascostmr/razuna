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
		
		<cftry>
			<cfadmin  action="verifyDatasource"  type="web"  password="password"  name="#datasource.name#"  dbusername="#datasource.username#" dbpassword="#datasource.password#">
			<cfset verified = true />
			<cfcatch type="any" >
				<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
			</cfcatch>
		</cftry>
		
		<cfreturn verified />
	</cffunction>
	
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
				
		<cfif arguments.hoststring is "">
			
			<!--- if we don't have a port, use the defaults for the database type
			<cfif arguments.port eq 0>
				<cfset defaultSettings = getDriverInfo(arguments.drivername) />
				
				<cfif structKeyExists(defaultSettings, "port")>
					<cfset arguments.port = defaultSettings.port />
				</cfif>
			</cfif> --->
	
			<cfset arguments.hoststring = formatJDBCURL(trim(arguments.drivername), trim(arguments.server), 
																trim(arguments.port), trim(arguments.databasename), arguments.connectstring, 
																arguments.filepath, trim(arguments.username), trim(arguments.password), 
																arguments.cacheResultSetMetadata, arguments.h2Mode, arguments.h2IgnoreCase) />
		<cfelse>
			<cfset arguments.port = "" />
			<cfset arguments.hoststring = trim(arguments.hoststring) />
			
			<cfif trim(arguments.connectstring) is not "">
				<cfset arguments.hoststring = arguments.hoststring & trim(arguments.connectstring) />
			</cfif>
			
			<cfset arguments.verificationquery = trim(arguments.verificationQuery) />
		</cfif>
		  
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
	
	<cffunction name="formatJDBCURL" access="private" output="false" returntype="string" 
			hint="Formats a JDBC URL for a specific database driver type">
		<cfargument name="drivername" type="string" required="true" hint="The name of the database driver class" />
		<cfargument name="server" type="string" required="true" hint="The database server name or IP address" />
		<cfargument name="port" type="numeric" required="true" hint="The database server port" />
		<cfargument name="database" type="string" required="true" hint="The database name" />
		<cfargument name="connectstring" type="string" required="false" hint="Additional conncetion information" />
		<cfargument name="filepath" type="string" required="false" default="" hint="The file path for a file-based database" />
		<cfargument name="username" type="string" required="false" default="" 
				hint="Database user name if one is to be included as part of the connection string. Mostly used for file-based databases." />
		<cfargument name="password" type="string" required="false" default="" 
				hint="Database password if one is to be included as part of the connection string. Mostly used for file-based databases." />
		<cfargument name="cacheResultSetMetadata" type="boolean" required="false" default="false" hint="MySQL specific setting" />
		<cfargument name="h2Mode" type="string" required="false" default="" hint="Compatibility mode for H2" />
		<cfargument name="h2IgnoreCase" type="boolean" required="false" default="true" 
				hint="Boolean indicating whether or not H2 should ignore case" />
		
		<cfset var jdbcURL = "" />
		
		<cfswitch expression="#arguments.drivername#">
			<!--- h2 embedded --->
			<cfcase value="org.h2.Driver">
				<!--- if the filepath is "" then use the default, and create it if it doesn't exist --->
				<cfif arguments.filepath is "">
					<!---<cfif variables.isMultiContextJetty>
						<cfset arguments.filepath = 
								"#getJVMProperty('jetty.home')##variables.separator.file#etc#variables.separator.file#openbd#variables.separator.file#h2databases" />
					<cfelse>
						<cfset arguments.filepath = expandPath("/db") />
					</cfif>--->
					
					<cfset arguments.filepath = expandPath("/db") />
					
					<cfif not directoryExists(arguments.filepath)>
						<cfdirectory action="create" directory="#arguments.filepath#" />
					</cfif>
				<cfelse>
					<!--- make sure the directory provided exists and throw an error if it doesn't; 
							probably best not to create it automatically in case it was just a typo, etc. --->
					<cfif not directoryExists(arguments.filepath)>
						<cfthrow message="The file path provided does not exist" type="bluedragon.adminapi.datasource" />
					</cfif>
				</cfif>

				<cfif right(arguments.filepath, 1) is "/" or right(arguments.filepath, 1) is "\">
					<cfset arguments.filepath = left(arguments.filepath, len(arguments.filepath) - 1) />
				</cfif>

				<!--- url format: jdbc:h2:/path_to_database;AUTO_SERVER=TRUE ... --->
				<!--- note that AUTO_SERVER=TRUE is necessary in order for the embedded database to respond to multiple threads --->
				<cfset jdbcURL = "jdbc:h2:#arguments.filepath##getFileSeparator()##arguments.database#;IGNORECASE=#arguments.h2IgnoreCase#" />
				
				<cfif arguments.h2Mode is not "H2Native">
					<cfset jdbcURL = jdbcURL & ";MODE=#arguments.h2Mode#" />
				</cfif>
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & ";" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- sql server -- microsoft driver --->
			<cfcase value="com.microsoft.sqlserver.jdbc.SQLServerDriver">
				<!--- url format: jdbc:sqlserver://[serverName[\instanceName][:portNumber]][;property=value[;property=value]] --->
				<cfset jdbcURL = "jdbc:sqlserver://#arguments.server#:#arguments.port#;databaseName=#arguments.database#" />
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & ";" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- sql server -- jtds driver --->
			<cfcase value="net.sourceforge.jtds.jdbc.Driver">
				<!--- url format: jdbc:jtds:<server_type>://<server>[:<port>][/<database>][;<property>=<value>[;...]] --->
				<cfset jdbcURL = "jdbc:jtds:sqlserver://#arguments.server#:#arguments.port#/#arguments.database#" />
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & ";" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- mysql --->
			<cfcase value="com.mysql.jdbc.Driver">
				<!--- url format: jdbc:mysql://[host][,failoverhost...][:port]/[database][?propertyName1][=propertyValue1][&propertyName2][=propertyValue2] --->
				<cfset jdbcURL = "jdbc:mysql://#arguments.server#:#arguments.port#/#arguments.database#?cacheResultSetMetadata=#arguments.cacheResultSetMetadata#&autoReconnect=true&useEncoding=true&characterEncoding=UTF-8" />
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & "&" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- oracle --->
			<cfcase value="oracle.jdbc.OracleDriver">
				<!--- url format: jdbc:oracle:thin:@server:port:SID --->
				<cfset jdbcURL = "jdbc:oracle:thin:@#arguments.server#:#arguments.port#:#arguments.database#" />
			</cfcase>
			
			<!--- postgres --->
			<cfcase value="org.postgresql.Driver">
				<!--- url format: jdbc:postgresql://host:port/database --->
				<cfset jdbcURL = "jdbc:postgresql://#arguments.server#:#arguments.port#/#arguments.database#" />
			</cfcase>
			
			<cfdefaultcase>
				<cfthrow message="Cannot format a JDBC URL for unknown driver types" type="bluedragon.adminapi.datasource" />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn jdbcURL />
	</cffunction>
	
	
	<cffunction name="getFileSeparator" access="public" output="false" returntype="string" 
			hint="Returns the platform-specific file separator">
				<cfreturn '/' />
		<!---<cfreturn getJVMProperty("file.separator") />--->
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
    
    <cffunction name="deleteDatasource" access="public" output="false">
        <cfargument name="dsn" type="any" required="true">
		<cftry>
			<cfadmin  action="removeDatasource"  type="web" password="password"  name="#arguments.dsn#"  remoteClients="arrayOfClients">
			<cfcatch type="any"></cfcatch>
		</cftry>
        <!--- Return --->
    	<cfreturn true>
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
	<cffunction name="logConsole" access="public" output="true" hint="Console output">
		<!--- Return --->
		<cfreturn true/>
	</cffunction>
	
	<cffunction name="convertHashBinary" access="public" output="false" returntype="any" hint="Returns a hashbinary value">
		<cfargument name="path" type="string" required="true" />
		<cfset returnValue = hash('#arguments.path#')/>
		<cfreturn returnValue />
	</cffunction>
		
</cfcomponent>