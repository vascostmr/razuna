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
	
	<cffunction name="setConfig" output="false">
		<cfset pathoneup = expandPath('../')>
		<cfadmin
			    action="updateDatasource"
			    type="web"
			    password="password"
			    classname="org.h2.Driver"
			    dsn="jdbc:h2:#pathoneup#\db\razuna_default;CACHE_SIZE=100000;IGNORECASE=TRUE;MODE=Oracle;AUTO_RECONNECT=TRUE;CACHE_TYPE=SOFT_LRU;AUTO_SERVER=TRUE"
			    name="razuna_default"
			    newName="razuna_default"    
			    dbusername="razuna"
			    dbpassword="razunaconfig"        
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
</cfcomponent>