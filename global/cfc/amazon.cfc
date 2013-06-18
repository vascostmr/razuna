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
<cfcomponent>

	<!---  --->
	<!--- STANDARD --->
	<!---  --->
	
	<cffunction name="onMissingMethod" returntype="any" access="public" output="false" hint="This method handles dynamic finders, properties, and association methods. It is not part of the public API.">
		<cfargument name="missingMethodName" type="string" required="true" hint="Name of method attempted to load.">
		<cfargument name="missingMethodArguments" type="struct" required="true" hint="Name/value pairs of arguments that were passed to the attempted method call.">
		<cfset var returnVariable = "">
		<cfif isstruct(server) and server.coldfusion.productname EQ "Railo">
			<cfinvoke component="amazon_railo" method="#arguments.missingMethodName#" argumentcollection="#arguments.missingMethodArguments#" returnvariable="returnVariable" >
			</cfinvoke>
		<cfelseif isstruct(server) and server.coldfusion.productname EQ "ColdFusion Server">
			<cfinvoke component="amazon_acf" method="#arguments.missingMethodName#" argumentcollection="#arguments.missingMethodArguments#" returnvariable="returnVariable" >
			</cfinvoke>
		<cfelse>
			<cfinvoke component="amazon_openBD" method="#arguments.missingMethodName#" argumentcollection="#arguments.missingMethodArguments#" returnvariable="returnVariable" >
			</cfinvoke>
		</cfif>
		
		<cfreturn returnVariable>
	</cffunction>	

</cfcomponent>
