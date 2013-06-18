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