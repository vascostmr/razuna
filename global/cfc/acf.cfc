<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false">
	<!--- get the configuration of server --->
	<cffunction name="getConfig" output="false" returntype="Any" hint="Returns a struct representation of the coldfusion server configuration">
		<cfset var localConfig = structNew()/>
			<cfset var server = "">
			<cflock scope="Server" type="readonly" timeout="5">
				<cfset apiObj = createObject("component",'CFIDE.adminapi.administrator').login('password')>
				<cfset admin = createObject("component",'CFIDE.adminapi.datasource').getDatasources()>
				<cfloop collection="#admin#" item="key">
					<cfset server = listAppend(server,key)>
				</cfloop>
				<cfset arr = listToArray(server)>
				<cfset localConfig.cfquery.datasource = arr>
			</cflock>
			<cfreturn localConfig/>
	</cffunction>
	
	<!--- Creates or updates a datasource --->
	<cffunction name="setDatasource" access="public" output="false" hint="Creates or updates a datasource">
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
		<!--- The current user is not authorized to invoke this method --->
		<cfset var localConfig = getConfig() />
		<cfset var defaultSettings = structNew() />
		<cfset var datasourceSettings = structNew() />
		<cfset var driver = 0 />
		<cfset var datasourceVerified = false />
		
		<!--- make sure configuration structure exists, otherwise build it --->
		<cfif (NOT StructKeyExists(localConfig, "cfquery")) OR (NOT StructKeyExists(localConfig.cfquery, "datasource"))>
			<cfset localConfig.cfquery.datasource = ArrayNew(1) />
		</cfif>
		<!--- login the ACF administrator --->
		<cfset apiObj = createObject("component" ,"cfide.adminapi.administrator").login('password')>
		
		<!--- if this is an update, delete the existing datasource --->
		<cfif arguments.action is "update">
			<cfset createObject("component",'CFIDE.adminapi.datasource').deleteDatasource(arguments.existingDatasourceName) />
			<cfset localConfig = getConfig() />
			
			<!--- if we're editing the only remaining datasource, need to recreate the datasource struture --->
			<cfif NOT StructKeyExists(localConfig, "cfquery") OR NOT StructKeyExists(localConfig.cfquery, "datasource")>
				<cfset localConfig.cfquery.datasource = ArrayNew(1) />
			</cfif>
		</cfif>
		
		<cfif arguments.hoststring is "">
	
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
		<cfif arguments.drivername IS "com.mysql.jdbc.Driver">
			<cfset structDSNs = createObject("component",'CFIDE.adminapi.datasource').setMySQL5(
															name="#arguments.name#",
															host="#arguments.server#",
															database="#arguments.databasename#",
															port="#arguments.port#",
															username="#arguments.username#",
															password="#arguments.password#"
														)>
		<cfelse>
			<cfset structDSNs = createObject("component","cfide.adminapi.datasource").setOther ( 
													name = arguments.name, 
													url = arguments.hoststring, 
													class = arguments.drivername, 
													driver = "H2",
													selectmethod = "cursor", 
													username = arguments.username,
													password = arguments.password,
											
											 		select = arguments.sqlselect, 
												    insert = arguments.sqlinsert, 
												    update = arguments.sqlupdate, 
												    delete = arguments.sqldelete, 
											
													maxconnections = arguments.maxconnections,
													timeout = arguments.connectiontimeout
											)>
		
		</cfif>

		 <cfreturn  true/>		
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
		<!--- Return --->
		<cfreturn jdbcURL />
	</cffunction>
	
	<!--- delete the database name already exists --->
	<cffunction name="deleteDatasource" access="public" output="false">
		<cfargument name="dsn" type="any" required="true">
		<cfset apiObj = createObject("component",'CFIDE.adminapi.datasource').deleteDatasource(arguments.dsn) />
		
		<!--- Return --->
		<cfreturn true>
	</cffunction>
	
	<!--- creating ZIP file --->
	<cffunction name="createZipFile" access="public" output="true">
       <cfargument name="ZIPFILE" type="string" required="true" />
       <cfargument name="source" type="string" required="true" />
       <cfargument name="recurse" type="string" required="true" />
	   <cfzip action="zip" file="#arguments.ZIPFILE#" source="#arguments.source#" recurse="#arguments.recurse#">

       <!--- Return --->
       <cfreturn true/>
    </cffunction>
    
     <!--- extract the ZIP file --->
	<cffunction name="extractZipFile" access="public" output="true">
       <cfargument name="ZIPFILE" type="string" required="true" />
       <cfargument name="destination" type="string" required="true" />

       <cfzip action="unzip" file="#arguments.ZIPFILE#" destination="#arguments.destination#" />
       <!--- Return --->
       <cfreturn true/>
    </cffunction>
    
     <!--- set catche --->
    <cffunction name="setCatche" access="public" output="false">
		<cfargument name="thefeed" type="any" required="true" />
    	<cfcache name="blog" action="cache" timespan="#CreateTimeSpan(0,6,0,0)#">
            <cfhttp url="#arguments.thefeed#" method="get" throwonerror="no" timeout="6">
        </cfcache>
		
		<!--- return --->
		<cfreturn true>
    </cffunction>
    
    <cffunction name="getDatasources" access="public" output="false" returntype="array" 
			hint="Returns an array containing all the data sources or a specified data source">
		<cfargument name="dsn" type="string" required="false" default="" hint="The name of the datasource to return" />
		
		
		<cfset var localConfig = getConfig() />
		<cfset var returnArray = "" />
		<cfset var dsnIndex = "" />
		<cfset var sortKeys = arrayNew(1) />
		<cfset var sortKey = structNew() />
		
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
				<cfif localConfig.cfquery.datasource[dsnIndex] EQ arguments.dsn>
					<cfset returnArray[1] = Duplicate(localConfig.cfquery.datasource[dsnIndex]) />
					<cfreturn returnArray />
				</cfif>
			</cfloop>
			<cfreturn ArrayNew(1)>
		</cfif>
	</cffunction>
	<!--- verifying the  Datasource name--->
	<cffunction name="verifyDatasource" access="public" output="false" returntype="any" 
			hint="Verifies a datasource">
		<cfargument name="dsn" type="string" required="true" hint="Datasource name to verify" />
		<cfset verified = false/>
		<cftry>
				<cfset verifyDSN = createObject("component",'CFIDE.adminapi.datasource').verifyDsn(arguments.dsn,true)>
				<cfif verifyDSN >
					<cfset verified = true />
				</cfif>
			<cfcatch type="any">
				<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
			</cfcatch>
		</cftry>
		
		<cfreturn verified />
	</cffunction>
	
	<cffunction name="logConsole" access="public" output="false" hint="Console output">
       <cfargument name="catch" type="any" required="true" default="true" >
	      
       <!--- Return --->
       <cfreturn true />
	</cffunction>
	
	<!--- Create spreadsheet --->
	<cffunction name="create_Spreadsheet" access="public" output="false" hint="Create spreadsheet in ACF">
		<cfargument name="thepath" type="string" required="true">
		<cfargument name="theqry" type="query" required="true">
		<cfargument name="theformat" type="string" required="true">
		<cfargument name="thename" type="string" required="true">
		<cfargument name="thefield" type="string" required="false" default="">
		<!--- Create Spreadsheet --->
		<cfif arguments.theformat EQ "xls">
			<cfset var sxls = spreadsheetnew()>
		<cfelseif arguments.theformat EQ "xlsx">
			<cfset var sxls = spreadsheetnew(true)>
		</cfif>
		<!--- Set header values --->
		<cfif arguments.thefield EQ "">
			<cfset var theheader =  arguments.theqry.columnList>
		<cfelse>
			<cfset var theheader = arguments.thefield>
		</cfif>
		<!--- Create header row --->
		<cfset SpreadsheetAddrow(sxls,theheader,1)>
		<cfset SpreadsheetFormatRow(sxls, {bold=TRUE, alignment="left"},1)>
		<!--- Add orders from query --->
		<cfset SpreadsheetAddRows(sxls,arguments.theqry,2)>
		<!---<cfset SpreadsheetFormatrow(sxls, {textwrap=false, alignment="vertical_top"}, 2)>
		<cfset SpreadsheetSetcolumnwidth(sxls, 1, 225)>
		<cfset SpreadsheetSetcolumnwidth(sxls, 2, 225)>
		<cfset SpreadsheetSetcolumnwidth(sxls, 3, 225)>
		<cfset SpreadsheetSetcolumnwidth(sxls, 4, 225)>
		<cfset SpreadsheetSetcolumnwidth(sxls, 5, 225)>
		<cfset SpreadsheetSetcolumnwidth(sxls, 6, 225)>--->
		<!--- Write file to file system --->
		<cfset SpreadsheetWrite(sxls,"#arguments.thepath#/outgoing/#arguments.thename#-#session.hostid#-#session.theuserid#.#arguments.theformat#",true)>
		<cfreturn true>
	</cffunction>
	
	<!--- query delete column --->
	<cffunction name="Query_Deletecolumn" access="public" output="false" hint="query delete column">
		<cfargument name="theqry" type="query" required="true">
		<cfargument name="thecolumn" type="string" required="true">
		<!--- set list variable --->
		<cfset var thecolumns = "">
		<cfloop list="#arguments.theqry.ColumnList#" index="Idx">
			<cfset var temp = findNoCase(Idx,arguments.thecolumn)>
			<!--- check the columns --->
			<cfif temp EQ 0>
				<cfset thecolumns = listAppend(thecolumns,Idx)>
			</cfif>
		</cfloop>
		<!--- extent the query --->
		<cfquery dbtype="query" name="remove">
			select #thecolumns#
			from arguments.theqry
		</cfquery>
		<!--- Return --->
		<cfreturn remove>
	</cffunction>
	
	<!--- create csv --->
	<cffunction name="create_csv" access="public" output="false" hint="create csv in ACF">
		<cfargument name="thepath" type="string" required="true">
		<cfargument name="theqry" type="query" required="true">
		<cfargument name="thename" type="string" required="true">
		<cfscript>
			var csv = "";
		    var cols = "";
		    var headers = "";
		    var i = 1;
		    var j = 1;
		    //create columns
		     cols = arguments.theqry.columnList;
		     //create header
    		 headers = cols;
    		 headers = listToArray(headers);
    		 for(i=1; i lte arrayLen(headers); i=i+1){
        			csv = csv & headers[i] & ",";
    			}
    		//create new line
    		csv = csv & chr(13) & chr(10);
    		//set column values
    		cols = listToArray(cols);
    		 for(i=1; i lte arguments.theqry.recordCount; i=i+1){
        			for(j=1; j lte arrayLen(cols); j=j+1){
            			csv = csv & arguments.theqry[cols[j]][i] & ",";
        			}        
        			csv = csv & chr(13) & chr(10);
    			}
		</cfscript>
		<!--- Write file to file system --->
		<cffile action="write" file="#arguments.thepath#/outgoing/#arguments.thename#-#session.hostid#-#session.theuserid#.csv" output="#csv#" addnewline="true">
		<cfreturn true>
	</cffunction>
	
	<!--- create datasourcename --->
	<cffunction name="createDatasource" access="public" output="false" hint="create datasourcename in coldfusion server">
		<cfargument name="action" type="string" required="true">
		<cfargument name="connectstring" type="string" required="true">
		<cfargument name="databasename" type="string" required="true">
		<cfargument name="drivername" type="any" required="true">
		<cfargument name="existingDatasourceName" type="string" required="true">
		<cfargument name="h2Mode" type="string" required="true">
		<cfargument name="hoststring" type="any" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="password" type="any" required="true">
		<cfargument name="port" type="numeric" required="true">
		<cfargument name="server" type="any" required="true">
		<cfargument name="username" type="any" required="true">
		<cfargument name="verificationQuery" type="any" required="true">
		
		<cfif arguments.drivername IS "com.mysql.jdbc.Driver">
			<cfset databaseapi = createObject("component",'CFIDE.adminapi.datasource').setMySQL5(
				name="#arguments.name#",
				host="#arguments.server#",
				database="#arguments.databasename#",
				port="#arguments.port#",
				username="#arguments.username#",
				password="#arguments.password#"
			)>
		</cfif>
		<cfreturn true>
	</cffunction>	

	<cffunction name="printPdf" access="public" output="false" >
		<!--- Return --->
		<cfreturn true/>
	</cffunction>
	
	<cffunction name="printPdfHeader" access="public" output="false" >
		<!--- Return --->
		<cfreturn true/>
	</cffunction>
	
	<cffunction name="printPdfFooter" access="public" output="false" >
		<!--- Return --->
		<cfreturn true/>
	</cffunction>
</cfcomponent>