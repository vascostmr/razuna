<cfcomponent>
	
	<cffunction name="getConfig" output="false" returntype="struct" hint="Returns a struct representation of the OpenBD server configuration (bluedragon.xml)">
		<cfset var admin = "" />
			<cflock scope="Server" type="readonly" timeout="5">
				<cfset admin = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").getConfig().getCFMLData() />
			</cflock>
		<cfreturn admin.server />
	</cffunction>
	
</cfcomponent>