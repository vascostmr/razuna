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
				<cfset createObject("component",'CFIDE.adminapi.administrator').login('password')>
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
		
		<!--- The current user is not authorized to invoke this method --->
		<cfset apiObj = createObject("component" ,"cfide.adminapi.administrator").login('password')>
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
		
		
		<!--- Other arguments
		originaldsn = "",
		string port="1433", boolean encryptpassword="true", description="", args, 
		 numeric MaxPooledStatements,  
		numeric interval, numeric login_timeout, numeric buffer, numeric blob_buffer, boolean enablemaxconnections,  
		boolean pooling="false", boolean disable, boolean disable_clob, boolean disable_blob, boolean disable_autogenkeys, 
		boolean create, boolean grant, boolean drop, boolean revoke, boolean alter, boolean storedproc, 
		 validationQuery="" )
		--->

		 <cfreturn  true/>		
	</cffunction>	

</cfcomponent>