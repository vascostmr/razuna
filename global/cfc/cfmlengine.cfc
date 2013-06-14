<cfcomponent>

	<cffunction name="onMissingMethod" returntype="any" access="public" output="false" hint="This method handles dynamic finders, properties, and association methods. It is not part of the public API.">
		<cfargument name="missingMethodName" type="string" required="true" hint="Name of method attempted to load.">
		<cfargument name="missingMethodArguments" type="struct" required="true" hint="Name/value pairs of arguments that were passed to the attempted method call.">
		
		<cfset var returnVariable = "">
		
		<cfif isstruct(server) and server.coldfusion.productname EQ "Railo">
			<cfinvoke component="railo" method="#missingMethodName#" returnvariable="returnVariable" >
			</cfinvoke>
		<cfelse>
			<cfinvoke component="openbd" method="#missingMethodName#" returnvariable="returnVariable" >
			</cfinvoke>
		</cfif>
		
		<cfreturn returnVariable>
	</cffunction>	
</cfcomponent>